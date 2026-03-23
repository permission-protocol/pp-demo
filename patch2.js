const fs = require('fs');
const file = '/Users/moltbot/.openclaw/workspace/pullmatch/app/app/page.tsx';
let content = fs.readFileSync(file, 'utf8');

// Instead of multiple replaces, let's just rewrite the hero-grid section.
// We'll extract everything between <div className="hero-grid items-center gap-12 pb-10 pt-10 lg:pt-16">
// and </div>\n        </div>\n      </section>

const regex = /<div className="hero-grid items-center gap-12 pb-10 pt-10 lg:pt-16">([\s\S]*?)<\/div>\s*<\/div>\s*<\/section>/;

const newHero = `<div className="flex flex-col lg:grid lg:grid-cols-2 items-center gap-8 lg:gap-12 pb-8 pt-6 lg:pt-16">
            <div data-reveal className="max-w-2xl flex flex-col justify-center text-center lg:text-left mx-auto lg:mx-0">
              <div className="flex justify-center lg:justify-start mb-4">
                <p className="inline-flex items-center gap-2 rounded-full border border-ember/20 bg-ember/8 px-4 py-1.5 text-[10px] sm:text-xs uppercase tracking-[0.24em] text-ember/90">
                  <span className="h-1.5 w-1.5 rounded-full bg-ember" />
                  Now in private beta
                </p>
              </div>
              <h1 className="font-display text-5xl uppercase leading-[0.95] text-paper sm:text-6xl lg:text-8xl tracking-tight">
                Swipe to Ship
                <span className="block mt-2 bg-gradient-to-r from-flame via-ember to-blush bg-clip-text text-transparent text-4xl sm:text-5xl lg:text-7xl">
                  Not a Dashboard
                </span>
              </h1>
              <p className="mt-4 max-w-xl mx-auto lg:mx-0 text-base leading-relaxed text-paper/76 sm:text-lg">
                Stop pretending you understand diffs. PullMatch reads every pull request, explains what changed in plain English, and lets you approve or reject with a swipe.
              </p>
              
              {/* MOBILE ONLY DEMO INJECTED HERE FOR TIGHT FLOW */}
              <div className="mt-8 mb-6 w-full max-w-sm mx-auto block lg:hidden relative">
                 <div className="absolute inset-0 -z-10 rounded-[3rem] bg-[radial-gradient(circle_at_top,rgba(255,107,74,0.28),transparent_55%),radial-gradient(circle_at_bottom,rgba(125,255,143,0.16),transparent_35%)] blur-2xl" />
                 <SwipeDemo />
              </div>

              <div className="mt-2 lg:mt-8 flex flex-col gap-4 w-full max-w-md mx-auto lg:mx-0">
                <a
                  href="/api/auth/signin/github"
                  className="w-full inline-flex min-h-14 items-center justify-center rounded-2xl bg-flame px-6 font-display text-base uppercase tracking-[0.1em] text-white shadow-lg transition hover:bg-flame/90 active:scale-[0.98]"
                >
                  Connect GitHub
                </a>
                <WaitlistForm />
              </div>
              
              <div className="mt-6 flex flex-col items-center lg:items-start">
                <SignupCounter />
              </div>
              
              <div className="mt-4 flex justify-center lg:justify-start">
                <SocialProofBar />
              </div>
              
              <div className="mt-6 hidden sm:flex flex-wrap gap-2 text-xs text-paper/56 justify-center lg:justify-start">
                <span className="rounded-full border border-white/10 px-3 py-1.5">Works with any GitHub repo</span>
                <span className="rounded-full border border-white/10 px-3 py-1.5">No git expertise required</span>
              </div>
            </div>

            <div data-reveal className="relative hidden lg:block w-full max-w-lg mx-auto">
              <div className="absolute inset-0 -z-10 rounded-[3rem] bg-[radial-gradient(circle_at_top,rgba(255,107,74,0.28),transparent_55%),radial-gradient(circle_at_bottom,rgba(125,255,143,0.16),transparent_35%)] blur-2xl" />
              <SwipeDemo />
            </div>
          </div>
        </div>
      </section>`;

content = content.replace(regex, newHero);
fs.writeFileSync(file, content);
