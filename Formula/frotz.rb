class Frotz < Formula
  desc "Infocom-style interactive fiction player"
  homepage "https://gitlab.com/DavidGriffith/frotz"
  url "https://gitlab.com/DavidGriffith/frotz/-/archive/2.50b2/frotz-2.50b2.tar.gz"
  sha256 "228046edeca45867af312ebffd2e6a83ed8df69dd161fbaf4ea818f789328cba"
  head "https://gitlab.com/DavidGriffith/frotz.git"

  bottle do
    sha256 "a47f879a4475b7ca3b35e481ae220a672023178536a8453b0a27cc34a705919b" => :catalina
    sha256 "bd7d173c661883a5ad370c4f2437dfcda10e2852988e4a1b0b681ee19335ed97" => :mojave
    sha256 "f1be9afe41e33396475d99511760690d3a46f9362fb2229e42ba48146d92f8f0" => :high_sierra
    sha256 "e190264a540f03ec98b7be45d1edfc73c0bd4946b4d2c4aacdf98521354e4ca0" => :sierra
    sha256 "6506ec53859a859eb71ab33511a11e9c957e0749cb25efa06d63d6c80d000b4a" => :el_capitan
    sha256 "887efd67a050038ffb15df8c713eaa40fcbfcc69d36f58373981dba3ccae422b" => :yosemite
  end

  def install
    inreplace "Makefile" do |s|
      s.remove_make_var! "CC"
      s.change_make_var! "PREFIX", prefix
      s.change_make_var! "SYSCONFDIR", etc
      s.change_make_var! "MANDIR", share
    end

    system "make", "nosound"
    system "make", "install"
  end
end
