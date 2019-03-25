import saliweb.backend
import os, sys, stat

class LogError(Exception): pass

class Job(saliweb.backend.Job):
    runnercls = saliweb.backend.WyntonSGERunner

    def run(self):
        os.chmod(".", 0775)
        par = open('input.txt', 'r')
        input_line = par.readline().strip()

        script = """
module load Sali
module load patch_dock imp
perl %s/runIDockServer.pl %s >& foxsdock.log
""" % (self.config.script_directory, input_line)

        r = self.runnercls(script)
        r.set_sge_options('-l arch=lx-amd64,h_rt=300:00:00,mem_free=4G -p 0')
        return r

    def postprocess(self):
        self.check_log_file()

    def check_log_file(self):
        """Check log file for common internal errors."""
        error = None
        with open('foxsdock.log') as fh:
            for line in fh:
                # This is usually caused by user error, so report it to them
                if 'PatchDock found no docking solutions' in line:
                    return
                if error is None and \
                   ('No such file' in line or "Can't find" in line
                    and "Can't find light chain" not in line
                    and "Can't find heavy chain" not in line
                    and "Can't find atom with atom index 0" not in line):
                    error = LogError("Job reported an error in foxsdock.log: %s"
                                     % line)
        if error:
            raise error

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

