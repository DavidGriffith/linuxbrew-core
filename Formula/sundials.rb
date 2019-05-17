class Sundials < Formula
  desc "Nonlinear and differential/algebraic equations solver"
  homepage "https://computation.llnl.gov/casc/sundials/main.html"
  url "https://computation.llnl.gov/projects/sundials/download/sundials-4.1.0.tar.gz"
  sha256 "280de1c27b2360170a6f46cb3799b2aee9dff3bddbafc8b08c291a47ab258aa5"
  revision 1

  bottle do
    root_url "https://linuxbrew.bintray.com/bottles"
    cellar :any
    sha256 "f0d3b4aa8224d34bded3dcb334af01413418c76803805d4c52202cb5d1acd41f" => :mojave
    sha256 "a892a1e43042b3bf22027f949efdead295a211cfba492cef2613dadf67ed79fe" => :high_sierra
    sha256 "a934b8dc4ca9ef13c001d5e75196e51858ffc58dd1de3c22b018ac10bc6effdc" => :sierra
    sha256 "3f72a46379e1ce885ec83ff00993f1953cc487aa161f3d84fdb25f7c148d867d" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "gcc" # for gfortran
  depends_on "open-mpi"
  depends_on "openblas"
  depends_on "suite-sparse"
  depends_on "python" unless OS.mac?

  def install
    blas = "-L#{Formula["openblas"].opt_lib} -lopenblas"
    args = std_cmake_args + %W[
      -DCMAKE_C_COMPILER=#{ENV["CC"]}
      -DBUILD_SHARED_LIBS=ON
      -DKLU_ENABLE=ON
      -DKLU_LIBRARY_DIR=#{Formula["suite-sparse"].opt_lib}
      -DKLU_INCLUDE_DIR=#{Formula["suite-sparse"].opt_include}
      -DLAPACK_ENABLE=ON
      -DBLA_VENDOR=OpenBLAS
      -DLAPACK_LIBRARIES=#{blas};#{blas}
      -DMPI_ENABLE=ON
    ]

    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    cp Dir[prefix/"examples/nvector/serial/*"], testpath
    args = %w[
      -I#{include}
      test_nvector.c
      sundials_nvector.c
      test_nvector_serial.c
      -L#{lib}
      -lsundials_nvecserial
    ]
    args << "-lm" if OS.linux?
    system ENV.cc, *args
    assert_match "SUCCESS: NVector module passed all tests",
                 shell_output("./a.out 42 0")
  end
end
