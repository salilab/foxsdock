import saliweb.build

vars = Variables('config.py')
env = saliweb.build.Environment(vars, ['conf/live.conf'], service_module='foxsdock')
Help(vars.GenerateHelpText(env))

env.InstallAdminTools()
env.InstallCGIScripts()

f = env.Frontend('idock')
f.InstallCGIScripts()
f.InstallHTML(['idock/html/metro/docs/bootstrap.js',
               'idock/html/metro/docs/jquery-1.8.0.js',
               'idock/html/metro/docs/jquery.validate.js',
               'idock/html/metro/docs/jquery.validate.unobtrusive.js',
               'idock/html/metro/docs/jquery.unobtrusive-ajax.js',
               'idock/html/metro/docs/font-awesome.css',
               'idock/html/metro/css/metro-bootstrap.css',
               'idock/html/idock.js'])
#f.InstallTXT(['idock/txt/help.txt', 'idock/txt/contact.txt'])



Export('env')
SConscript('python/foxsdock/SConscript')
SConscript('lib/SConscript')
SConscript('txt/SConscript')
SConscript('test/SConscript')
