import saliweb.backend
import os, sys, stat

class LogError(Exception): pass

class Job(saliweb.backend.Job):
    runnercls = saliweb.backend.SGERunner

    def run(self):
        os.chmod(".", 0775)
        par = open('input.txt', 'r')
        input_line = par.readline().strip()

        script = """
module load patch_dock imp
perl %s/runIDockServer.pl %s >& foxsdock.log
""" % (self.config.script_directory, input_line)

        r = self.runnercls(script)
        r.set_sge_options('-l arch=linux-x64,h_rt=300:00:00,mem_free=4G -p 0')
        #r.set_sge_options('-l arch=linux-x64,mem_free=4G -p 0')
        return r

    def postprocess(self):
        self.check_log_file()

    def check_log_file(self):
        """Check log file for common errors."""
        with open('foxsdock.log') as fh:
            for line in fh:
                if 'No such file' in line or "Can't find" in line:
                    raise LogError("Job reported an error in foxsdock.log: %s"
                                   % line)

    def complete(self):
        os.chmod(".", 0775)

class Config(saliweb.backend.Config):
    def populate(self, config):
        saliweb.backend.Config.populate(self, config)
        # Read our service-specific configuration
        self.script_directory = config.get('foxsdock', 'script_directory')


def get_web_service(config_file):
    db = saliweb.backend.Database(Job)
    config = Config(config_file)
    return saliweb.backend.WebService(config, db)

