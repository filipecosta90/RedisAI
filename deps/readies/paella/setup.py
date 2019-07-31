
import os
import sys
import tempfile
from .platform import OnPlatform, Platform

#----------------------------------------------------------------------------------------------

class Runner:
    def __init__(self, nop=False):
        self.nop = nop

    def run(self, cmd, output_on_error=False):
        print(cmd)
        sys.stdout.flush()
        if self.nop:
            return
        if output_on_error:
            fd, temppath = tempfile.mkstemp()
            os.close(fd)
            cmd = "{{ {}; }} >{} 2>&1".format(cmd, temppath)
        rc = os.system(cmd)
        if rc > 0:
            if output_on_error:
                os.system("cat {}".format(temppath))
                os.remove(temppath)
            eprint("command failed: " + cmd)
            sys.stderr.flush()
            sys.exit(1)

    def has_command(self, cmd):
        return os.system("command -v " + cmd + " > /dev/null") == 0

#----------------------------------------------------------------------------------------------

class RepoRefresh(OnPlatform):
    def __init__(self, runner):
        OnPlatform.__init__(self)
        self.runner = runner

    def redhat_compat(self):
        pass
    
    def debian_compat(self):
        self.runner.run("apt-get -qq update -y")

#----------------------------------------------------------------------------------------------

class Setup(OnPlatform):
    def __init__(self, nop=False):
        OnPlatform.__init__(self)
        self.runner = Runner(nop)
        self.stages = [0]
        self.platform = Platform()
        self.os = self.platform.os
        self.dist = self.platform.dist
        self.ver = self.platform.os_ver
        
        if self.has_command("python"):
            self.python = "python"
        elif self.has_command("python2"):
            self.python = "python2"

        if self.os == 'macosx':
            # this is required because osx pip installed are done with --user
            os.environ["PATH"] = os.environ["PATH"] + ':' + '$HOME/Library/Python/2.7/bin'
        
        if self.platform.is_debian_compat():
            # prevents apt-get from interactively prompting
            os.environ["DEBIAN_FRONTEND"] = 'noninteractive'
        
        os.environ["PYTHONWARNINGS"] = 'ignore:DEPRECATION::pip._internal.cli.base_command'

    def setup(self):
        RepoRefresh(self.runner).invoke()
        self.invoke()

    def run(self, cmd, output_on_error=False):
        return self.runner.run(cmd, output_on_error=output_on_error)

    def has_command(self, cmd):
        return self.runner.has_command(cmd)

    #------------------------------------------------------------------------------------------

    def apt_install(self, packs, group=False):
        self.run("apt-get -qq install -y " + packs, output_on_error=True)

    def yum_install(self, packs, group=False):
        if not group:
            self.run("yum install -q -y " + packs, output_on_error=True)
        else:
            self.run("yum groupinstall -y " + packs, output_on_error=True)

    def dnf_install(self, packs, group=False):
        if not group:
            self.run("dnf install -y " + packs, output_on_error=True)
        else:
            self.run("dnf groupinstall -y " + packs, output_on_error=True)

    def zypper_install(self, packs, group=False):
        self.run("zipper --non-interactive install " + packs, output_on_error=True)

    def pacman_install(self, packs, group=False):
        self.run("pacman --noconfirm -S " + packs, output_on_error=True)

    def brew_install(self, packs, group=False):
        self.run('brew install ' + packs, output_on_error=True)

    def install(self, packs, group=False):
        if self.os == 'linux':
            if self.dist == 'fedora':
                self.dnf_install(packs, group)
            elif self.dist == 'ubuntu' or self.dist == 'debian':
                self.apt_install(packs, group)
            elif self.dist == 'centos' or self.dist == 'redhat':
                self.yum_install(packs, group)
            elif self.dist == 'suse':
                self.zypper_install(packs, group)
            elif self.dist == 'arch':
                self.pacman_install(packs, group)
            else:
                Assert(False), "Cannot determine installer"
        elif self.os == 'macosx':
            self.brew_install(packs, group)
        else:
            Assert(False), "Cannot determine installer"

    def group_install(self, packs):
        self.install(packs, group=True)

    #------------------------------------------------------------------------------------------

    def pip_install(self, cmd):
        pip_user = ''
        if self.os == 'macosx':
            pip_user = '--user '
        self.run("pip install --disable-pip-version-check " + pip_user + cmd, output_on_error=True)

    def pip3_install(self, cmd):
        pip_user = ''
        if self.os == 'macosx':
            pip_user = '--user '
        self.run("pip3 install --disable-pip-version-check " + pip_user + cmd, output_on_error=True)

    def setup_pip(self):
        get_pip = "set -e; cd /tmp; curl -s https://bootstrap.pypa.io/get-pip.py -o get-pip.py"
        if not self.has_command("pip"):
            self.install("curl")
            self.run(get_pip + "; " + self.python + " get-pip.py", output_on_error=True)
        ## fails on ubuntu 18:
        # if not has_command("pip3") and has_command("python3"):
        #     run(get_pip + "; python3 get-pip.py")
