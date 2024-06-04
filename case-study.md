## Case Study:

1. The app seems to be outdated. Readme + Algolia instructions no longer work out of the box.
   Trying to figure out how to start the app.
   Or trying to launch the app without docker.
2. The migrations are outdated, had to change them to ActiveRecord::Migration[5.1]
3. Migrations gave an error "Index already exists". Fixed that.
   The app launched.
   Setting up local_production environment + configs that will contain settings for all environments.
   Done a proof-of-concept.
4. Changing docker-compose.yml to launch the app in local_production environment.
   A lot of work related to setting up the local_production postgres db.
   Had to log into docker container and edit database.yml inside it to make local_production DB work.
5. Installing Skylight
   Updated the Skylight gem.
   Following setup instructions on https://www.skylight.io/app/setup
   It's supposed to automatically detect my app.
   Manually setting up Skylight faild too - it required a Github organization that I didn't have.
   Skipping Skylight for now.
6. Skipping other tools that I set up in Homework 3 (Newrelic, RackMiniProfiler, etc)
7. Solving actual optimization homework (StoriesController#index)
   The controller seems to be a complete mess.
   Trying to optimize it would require running seeds (which will not run on production).
   Running seeds on development environment.
8. Updated Bullet. No new issues found.
9. Installed rack-mini-profiler. Found N+1 issues not related to the original task.
10. Investigating the task related to optimizing a partial "single_story.html.erb"
    Installing Apache Benchmarks (ab) to test the performance of the page http://localhost:3000/.
    The task says that a partial "single_story.html.erb" can be cached.
    It takes 400ms to render the page on average (too slow)
    When I comment out the single_story partial, the page renders in 200ms in average.
    So there is an improvement.
    Trying to cache the page.
11. Dev environment is not caching by default. Enabled rails dev:cache. Put a cache block around the erb.
    Did the command touch tmp/caching-dev.txt as per the instructions.
    Fixed the development.rb configuration issue (perform_caching was false, set it to true)
    Now, the slowest load time is 156ms.
    Task completed.

## Lecture Notes

Little law (counting how many instances we need)
I = L \* T
L = load (e.g. 200 req/sec)
T = response time (e.g. 1/100 sec/request)
I = number of instances (e.g. 2 in this case)

However
L is not constant (# of requests per second changes over time)
T is not constant (we get a histogram where the majority of requests is fast, while some requests are slow)

Nate Berkopec rule of thumb: the slowest 5% of requests hsould be <= 4 \* average response time

So our job is to optimize those 95%+ of requests (last 5% of longest requests)
Set up monitoring and self-optimizing system.

Dev.to: real open source rails project for optimization excerise
cloc (brew install cloc): count lines of code per language

Skylight (repetitions ranking - popularity \* time spent = agony rank)
NewRelic (APM - application performance monitoring) - also has histagram of response times

Apdex = (satisfied + tolerating/2) / total
Satisfied: response time < 0.8s
Tolerating: response time < 2.1s
Total: all requests

Scout: monitoring tool
DataDog: monitoring tool

ELK stack: ElasticSearch, Logstash, Kibana
Prometheus + Grafana + Prometheus Exporter: monitoring tool
Yabeda: monitoring tool

Local Production with dump from production database

Load Teesting Tools:
Apache Benchmarks (ab)
siege (brew install siege)
wrk (brew install wrk)

def method
StackProf.run(mode: :cpu, out: 'tmp/stackprof-cpu-myapp.dump') do # code to profile
end
end

or

around_action :stackprof_sample, only: [:index]

def stackprof_sample(&block)
StackProf.run(mode: :cpu, out: 'tmp/stackprof-cpu-myapp.dump') do
block.call
end
end

(!)

# application.rb

config.middleware.use(Rack::RubyProf, :path => 'tmp/ruby-prof')

or

# application.rb

class ProfilerMiddleware
def initialize(app)
@app = app
end

def call(env)
RubyProf.measure_mode = RubyProf::MEMORY
RubyProf.start
status, headers, response = @app.call(env)
result = RubyProf.stop
File.open('tmp/ruby-prof.dump', 'w') do |f|
RubyProf::CallStackPrinter.new(result).print(f)
end
[status, headers, response]
end
end

possible pitfalls that need to be optimized:

- N+1
- partials in loops - should do render "partial", collection: @collection
- doing unnecessary work
- redoing the work unnecessarily
- bloat
- non-freezing strings

Caching:

- Fragment caching
- Russian doll caching
- Action caching (page from nginx only if before filters allow to see it)
- Page caching (entire page is on nginx)
- Low-level caching
- Custom caching
- HTTP caching

Jobs:

- Make them so that it's OK if they launch more than once.
- Simple params
- Simple jobs
- Queues for each type of jobs
- Timeout
- Retries
- Send errors from jobs to Rollbar, etc
- Onen job can launch 1000 smaller jobs - don't launch all jobs from the main thread.
