import saliweb.build

vars = Variables('config.py')
env = saliweb.build.Environment(vars, ['conf/live.conf'], service_module='foxsdock')
Help(vars.GenerateHelpText(env))

env.InstallAdminTools()
env.InstallCGIScripts()

Export('env')
SConscript('python/foxsdock/SConscript')
SConscript('lib/SConscript')
SConscript('html/SConscript')
SConscript('txt/SConscript')
SConscript('test/SConscript')
