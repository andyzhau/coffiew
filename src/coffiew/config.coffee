# Configuration of coffiew.
# Author: Andy Zhao(andy@nodeswork.com)

env =
  isBrowser: window?
  isNode: process?
  onError: (path, options, err) ->
    console.err "coffiew render failed for #{path} with options[#{options}]"
    console.err err.stack

module.exports = config =

  env: env

  error: (onError) ->
    env.onError = onError
