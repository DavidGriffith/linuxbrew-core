class Borgmatic < Formula
  include Language::Python::Virtualenv

  desc "Simple wrapper script for the Borg backup software"
  homepage "https://torsion.org/borgmatic/"
  url "https://github.com/witten/borgmatic/archive/1.3.23.tar.gz"
  sha256 "257bb3b684fe14025043efd0e38363cde9e30fce21c1ceeb61ac04987b35fbd6"

  bottle do
    cellar :any_skip_relocation
    sha256 "e5c7e1c6cd395de09dd36a4d061d2f933bbef4de374aa465da331707a79dca74" => :catalina
    sha256 "c5d9fc22d54efa35ce509c0b3d22d5d3a6295b03c30583ddcff3545423b1073c" => :mojave
    sha256 "cf771590388af5590dbb59201912097dc36dacbfedb9c4d11011b1b14c47d861" => :high_sierra
    sha256 "f40855dc74853ed8d11c488b3d39a649228a7aa7ce282b302d08f94137e37017" => :x86_64_linux
  end

  depends_on "python"

  resource "six" do
    url "https://files.pythonhosted.org/packages/16/d8/bc6316cf98419719bd59c91742194c111b6f2e85abac88e496adefaf7afe/six-1.11.0.tar.gz"
    sha256 "70e8a77beed4562e7f14fe23a786b54f6296e34344c23bc42f07b15018ff98e9"
  end

  resource "docopt" do
    url "https://files.pythonhosted.org/packages/source/d/docopt/docopt-0.6.2.tar.gz"
    sha256 "49b3a825280bd66b3aa83585ef59c4a8c82f2c8a522dbe754a8bc8d08c85c491"
  end

  resource "PyYAML" do
    url "https://files.pythonhosted.org/packages/9e/a3/1d13970c3f36777c583f136c136f804d70f500168edc1edea6daa7200769/PyYAML-3.13.tar.gz"
    sha256 "3ef3092145e9b70e3ddd2c7ad59bdd0252a94dfe3949721633e41344de00a6bf"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/a0/b0/a4e3241d2dee665fea11baec21389aec6886655cd4db7647ddf96c3fad15/python-dateutil-2.7.3.tar.gz"
    sha256 "e27001de32f627c22380a688bcc43ce83504a7bc5da472209b4c70f02829f0b8"
  end

  resource "pykwalify" do
    url "https://files.pythonhosted.org/packages/53/6a/c7394df238816085de6a630f1817805639e844ea7980108f19261cd44c12/pykwalify-1.7.0.tar.gz"
    sha256 "7e8b39c5a3a10bc176682b3bd9a7422c39ca247482df198b402e8015defcceb2"
  end

  resource "ruamel.yaml" do
    url "https://files.pythonhosted.org/packages/88/df/4f095aa617391f789a8df22d3b44fbaf7274dd90dc4982b2fb0637a0fbbc/ruamel.yaml-0.15.92.tar.gz"
    sha256 "c6d05e38a141922eca7902135e7a40b605763d6da8ec6624517370631ce9fb6d"
  end

  resource "colorama" do
    url "https://files.pythonhosted.org/packages/76/53/e785891dce0e2f2b9f4b4ff5bc6062a53332ed28833c7afede841f46a5db/colorama-0.4.1.tar.gz"
    sha256 "05eed71e2e327246ad6b38c540c4a3117230b19679b875190486ddd2d721422d"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    borg = (testpath/"borg")
    config_path = testpath/"config.yml"
    repo_path = testpath/"repo"
    log_path = testpath/"borg.log"

    # Create a fake borg executable to log requested commands
    borg.write <<~EOS
      #!/bin/sh
      echo $@ >> #{log_path}

      # Return error on info so we force an init to occur
      if [ "$1" = "info" ]; then
        exit 1
      fi
    EOS
    borg.chmod 0755

    # Generate a config
    system bin/"generate-borgmatic-config", "--destination", config_path

    # Replace defaults values
    config_content = File.read(config_path)
                         .gsub(/# ?local_path: borg1/, "local_path: #{borg}")
                         .gsub(/user@backupserver:sourcehostname.borg/, repo_path)
    File.open(config_path, "w") { |file| file.puts config_content }

    # This does not work in newer version
    # Initialize Repo
    # system bin/"borgmatic", "-v", "2", "-n", "--config", config_path, "--init", "--encryption", "repokey"

    # Create a backup
    system bin/"borgmatic", "--config", config_path

    # See if backup was created
    system bin/"borgmatic", "--config", config_path, "--list", "--json"

    # Read in stored log
    log_content = File.read(log_path)

    # Assert that the proper borg commands were executed
    assert_equal <<~EOS, log_content
      prune --keep-daily 7 --prefix {hostname}- #{repo_path}
      create #{repo_path}::{hostname}-{now:%Y-%m-%dT%H:%M:%S.%f} /home /etc /var/log/syslog*
      check --prefix {hostname}- #{repo_path}
      list --json #{repo_path}
    EOS
  end
end
