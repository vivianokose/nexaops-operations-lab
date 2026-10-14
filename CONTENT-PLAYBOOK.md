# Content Playbook — nexaops-operations-lab

How I document and publish every module. This is the detailed reference that used to live
in the Project instructions (sections 08, 08b, 09, 10). It is kept here so the live
instructions stay short. Read this file at the END of a module, once the learning phase is
done and it's time to produce docs and posts.

Repo: nexaops-operations-lab (github.com/vivianokose/nexaops-operations-lab)

---

## Screenshots

- I save screenshots to my Desktop per module (e.g.
  C:\Users\chiam\Desktop\nexaops-operations-lab\05-cloud-iaas), then copy them into the
  repo. In WSL that path is /mnt/c/Users/chiam/Desktop/... . My Desktop folder name may not
  exactly match the repo folder name; confirm the real path when copying.
- AT THE START of each module, suggest the screenshot folder name and the full list of
  screenshot filenames upfront, so I save them correctly from the beginning.
- I sometimes keep intentional "duplicate/II" screenshots on purpose. Don't flag those.
- In GitHub READMEs, reference every screenshot with RELATIVE paths, inline ![](path)
  markdown, so they render and sit next to the step they illustrate. Relative paths are
  relative to the README's own folder (a README at 06-nexus/README.md references
  (screenshots/file.png) and (architecture.png), NOT (06-nexus/...)). Relative paths are the
  right call for READMEs: they render in the PR preview and on main, and never break on a
  branch. If a README's images aren't rendering, first check the screenshots are actually
  committed to the branch you're viewing. (Raw-GitHub URLs are the blog pattern below, not
  the README pattern.)
- In blog posts (dev.to, Hashnode, Medium, Substack), embed screenshots as REAL, rendering
  markdown image tags that point at the raw GitHub URL of the file in my repo, e.g.
  ![alt text](https://raw.githubusercontent.com/vivianokose/nexaops-operations-lab/main/<module-folder>/screenshots/<file>.png)
  with a short *italic caption* line underneath each. Do NOT use [SCREENSHOT: ...] text
  placeholders; those are awkward to edit around. The raw-GitHub links render on the blog
  platforms automatically because my repo is public, so I don't upload images by hand. (If
  my repo is ever private, fall back to manual upload.)
- Set the blog's cover_image in the frontmatter to a raw GitHub URL of the best screenshot,
  so dev.to and Hashnode pick it up automatically.
- This requires the screenshots to already be committed and pushed to my repo before I
  publish the post, so sequence the repo commit before the posts.

## Documentation and architecture diagrams

- Every module's docs should include an ARCHITECTURE DIAGRAM showing how the pieces fit.
- Diagrams intended for GitHub READMEs must be committed as PNG, not SVG. GitHub sanitizes
  SVGs embedded in markdown and they render blank. PNG always renders. (Keep an SVG source
  in the repo if useful, but the README references the PNG.)
- Make all docs visually polished, well-structured, and professional, something a working
  engineer would proudly publish. Suggest and recommend improvements where useful.
- Diagrams may also be embedded in blog posts (where SVG is fine on the blog platforms).

## Content workflow (end of every module)

Every completed module produces content, after the learning phase is done. Frame everything
as real engineering work, not a training exercise. Docs should look like something a working
engineer published.

Commit and push the module's screenshots AND diagrams to the repo BEFORE writing the posts,
so the blog posts can embed them as rendering raw-GitHub image links (see Screenshots above).
Posts should come out publish-ready, with real images and captions, no manual image
uploading and no placeholder text to clean up.

My standing publishing set (publish in this order; Hashnode is the canonical home and the
others set their canonical URL back to the Hashnode post):

- Hashnode (vivianokose.hashnode.dev): THE canonical home. Same depth as dev.to, slightly
  more personal intro. Publish here first, then reuse its URL as the canonical elsewhere.
- Dev.to: full walkthrough with code, commands, explanations. Beginner-friendly. Tagged.
  Reads frontmatter directly (title, tags, canonical_url, cover_image), so it's near
  copy-paste.
- Medium: narrative-driven. Story + technical. Broader audience. Note: Medium's "import a
  story" often only grabs the header/footer and misses the body; fall back to copying from
  the rendered Hashnode page, which brings the images. Set canonical to Hashnode.
- Substack: newsletter-first, personal "here's where I am in the journey" voice, with an
  inbox-style subject-line title and preview text. For a launch, a multi-post intro sequence
  works well: (1) introduce myself, (2) set expectations for the newsletter, (3) recap the
  journey so far, (4) bring subscribers up to speed with the current module. Supports
  scheduling; queue posts in advance. Set canonical to Hashnode for posts that duplicate a
  blog.
- LinkedIn (okosechiamaka): 4-5 posts per module, varied enough that they don't feel
  repetitive, with genuine punch in the opening line of each. Each post includes a SET of
  images (multiple, in order) that tell the story visually as a gallery, not a single image;
  list the images per post. Provide a posting SCHEDULE (every 2-3 days) so posts can be
  queued across the next module and keep my feed active while I study. Mix the angles: honest
  struggle/journey, technical depth, and recruiter-facing framing. Lead with what was built
  and learned. Human tone. Include a "first comment" I post myself under each (150-300 words
  for the main post).

### LinkedIn engagement (learned the hard way; apply to every post)

- POST THE FIRST COMMENT WITHIN A MINUTE of publishing, every time. Not later. Early comments
  are what tell LinkedIn a post is worth showing, and most of my early posts underperformed
  because nothing seeded them.
- The first comment should ADD something the post doesn't say: a specific detail, a
  confession about what I nearly got wrong, or a callback connecting it to a later module.
  Not a summary of the post.
- KEEP LINKS OUT OF THE POST BODY. Links suppress reach. Put the repo/blog link in the first
  comment instead.
- MOMENT-SHAPED POSTS BEAT CAPABILITY LISTS. My best-performing posts were "something
  happened, I reacted, I was wrong, then I understood" (the deliberate lockout hit 257
  impressions). Bullet lists of what I can now do consistently did a third of that.
  Deliberate-failure posts travel especially well.
- End the post on something ANSWERABLE where it feels natural. Not "thoughts?" but a specific
  question people can actually answer. Don't force it.
- REPLIES: thank them BY NAME, then add one small thing. Two lines is right for a compliment.
  Only a genuine technical question or disagreement warrants a full paragraph. Don't end
  replies with a question unless it's genuinely natural; I'd rather close warmly on something
  of my own than hand it back.
- Don't lead recruiter-facing posts with "N modules into my training". It frames me as a
  learner before the reader sees the work. Lead with the capability; let the training context
  come later if at all.

Optional / occasional:
- X / Twitter (only when I ask): hook first line, 1-3 tweets, link to the long-form.
- Threads (only when I ask): casual, conversational mini-story, 3-7 short posts.
- Cross-link my best pieces to my own GitHub Pages site (viviancloud.site) as the hub.
- Aim a standout flagship piece at freeCodeCamp News occasionally for credibility.
- daily.dev to surface posts to a wider dev audience.

For every module's posts: use the labs' own post templates where helpful, give the right
hashtags per platform, and give SEO guidance including CANONICAL URLs across platforms (so
duplicate cross-posts point to one home version) and meta titles/descriptions.

## My voice (for all content)

Honest and a bit raw, but warm. Clean. NO emojis. Medium-length lines with breathing room.
The struggles and the fixes are the story, not just the wins. Relatable to peers, useful to
beginners, credible to recruiters. Every piece works as both proof of skill and a resource
someone else can learn from. Keep it original and fresh each time; don't lean on the same
personal anecdote repeatedly.

My writing is meant to do two things at once: help me get hired AND help others who are
learning. Keep both audiences in mind.

Common hashtags: #DevOps #CloudEngineering #100DaysOfCloud #WomenInTech #LearningInPublic
(adjust per platform and topic; e.g. add #AWS, #DevSecOps, #Linux, #CICD where relevant).

## Writing and communication rules (apply to all content, same as the live instructions)

- NO long dashes, em dashes, or double hyphens anywhere.
- NO corporate language: no "leverage", "synergy", "utilize", "streamline", "I am pleased to
  announce", "I am proud to share".
- No dense paragraphs; keep them short. Explain the "why", not just the "what".
- Write like a real person talks: warm, direct, clear. Varied sentence lengths. Avoid
  anything robotic or AI-sounding.
- Never open with "How I..." or "In today's fast-paced world...".
- Always explain technical terms simply. Audience is mixed: beginners, recruiters,
  non-technical readers.
