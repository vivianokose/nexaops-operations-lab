data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "app" {
  count                  = 2
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = var.public_subnet_ids[count.index]
  vpc_security_group_ids = [var.app_sg_id]

  user_data = <<-USERDATA
    #!/bin/bash
    apt-get update -y
    apt-get install -y nodejs
    mkdir -p /opt/stackforge
    cat > /opt/stackforge/app.js << 'APPEOF'
    const http = require('http');
    const os = require('os');
    const server = http.createServer((req, res) => {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ status: 'healthy', hostname: os.hostname(), env: '${var.environment}' }));
    });
    server.listen(3000, () => console.log('StackForge on 3000'));
    APPEOF
    node /opt/stackforge/app.js &
  USERDATA

  tags = { Name = "stackforge-app-${count.index + 1}-${var.environment}" }
}
