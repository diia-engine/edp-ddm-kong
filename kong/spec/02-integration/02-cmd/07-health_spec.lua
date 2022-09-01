local helpers = require "spec.helpers"

describe("kong health", function()
  lazy_setup(function()
    helpers.prepare_prefix()
  end)
  lazy_teardown(function()
    helpers.clean_prefix()
  end)
  after_each(function()
    helpers.kill_all()
  end)

  it("health help", function()
    local _, stderr = helpers.kong_exec "health --help"
    assert.not_equal("", stderr)
  end)
  it("succeeds when Kong is running with custom --prefix", function()
    assert(helpers.kong_exec("start --conf " .. helpers.test_conf_path))

    local _, _, stdout = assert(helpers.kong_exec("health --prefix " .. helpers.test_conf.prefix))
    assert.matches("nginx%.-running", stdout)
    assert.matches("Kong is healthy at " .. helpers.test_conf.prefix, stdout, nil, true)
  end)
  it("fails when Kong is not running", function()
    local ok, stderr = helpers.kong_exec("health --prefix " .. helpers.test_conf.prefix)
    assert.False(ok)
    assert.matches("Kong is not running at " .. helpers.test_conf.prefix, stderr, nil, true)
  end)

  describe("errors", function()
    it("errors on inexisting prefix", function()
      local ok, stderr = helpers.kong_exec("health --prefix inexistant")
      assert.False(ok)
      assert.matches("no such prefix: ", stderr, nil, true)
    end)
  end)
end)
