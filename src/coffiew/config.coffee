# Configuration of coffiew.
# Author: Andy Zhao(andy@nodeswork.com)

env =
  isBrowser: window?
  isNode: process?

module.exports = config =

  env: env
