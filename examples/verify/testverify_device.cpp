#include <cmath> // Without this, abs returns zero!
#include <random>
#include "fftx3.hpp"
#include "fftx3utilities.h"

#include "VerifyTransform.hpp"

#ifdef FFTX_HIP
void verify3d(fftx::box_t<3> a_domain,
              fftx::box_t<3> a_fdomain,
              int a_rounds,
              deviceTransform3dType<std::complex<double>, std::complex<double>>& a_mddft,
              deviceTransform3dType<std::complex<double>, std::complex<double>>& a_imddft,
              deviceTransform3dType<double, std::complex<double>>& a_prdft,
              deviceTransform3dType<std::complex<double>, double>& a_iprdft,
              int a_verbosity)
{
  fftx::point_t<3> fullExtents = a_domain.extents();

  {
    std::string name = "mddft";
    std::cout << "***** test 3D MDDFT on complex "
              << a_domain << std::endl;
    TransformFunction<3, std::complex<double>, std::complex<double>>
      fun(a_mddft, a_domain, a_domain, fullExtents, name, -1);
    VerifyTransform<3, std::complex<double>, std::complex<double>>
      (fun, a_rounds, a_verbosity);
    // verifyTransform(a_mddft, a_domain, a_domain, fullextents, -1, a_rounds, a_verbosity);
  }

  {
    std::string name = "imddft";
    std::cout << "***** test 3D IMDDFT on complex "
              << a_domain << std::endl;
    TransformFunction<3, std::complex<double>, std::complex<double>>
      fun(a_imddft, a_domain, a_domain, fullExtents, name, 1);
    VerifyTransform<3, std::complex<double>, std::complex<double>>
      (fun, a_rounds, a_verbosity);
    // verifyTransform(a_imddft, a_domain, a_domain, fullextents, 1, a_rounds, a_verbosity);
  }

  {
    std::string name = "mdprdft";
    std::cout << "***** test 3D PRDFT from real "
              << a_domain << " to complex " << a_fdomain << std::endl;
    TransformFunction<3, double, std::complex<double>>
      fun(a_prdft, a_domain, a_fdomain, fullExtents, name, -1);
    VerifyTransform<3, double, std::complex<double>>
      (fun, a_rounds, a_verbosity);
    // verifyTransform(a_prdft, a_domain, a_fdomain, fullextents, -1, a_rounds, a_verbosity);
  }

  {
    std::string name = "imdprdft";
    std::cout << "***** test 3D IPRDFT from complex "
              << a_fdomain << " to real " << a_domain << std::endl;
    TransformFunction<3, std::complex<double>, double>
      fun(a_iprdft, a_fdomain, a_domain, fullExtents, name, 1);
    VerifyTransform<3, std::complex<double>, double>
      (fun, a_rounds, a_verbosity);
    // verifyTransform(a_iprdft, a_fdomain, a_domain, fullextents, 1, a_rounds, a_verbosity);
  }
}
#endif                    

int main(int argc, char* argv[])
{
#ifdef FFTX_HIP
  // { SHOW_CATEGORIES = 1, SHOW_SUBTESTS = 2, SHOW_ROUNDS = 3};
  printf("Usage:  %s [nx] [ny] [nz] [verbosity=0] [rounds=20]\n", argv[0]);
  printf("verbosity 0 for summary, 1 for categories, 2 for subtests, 3 for rounds\n");
  if (argc <= 3)
    {
      printf("Missing dimensions\n");
      exit(0);
    }
  const int nx = atoi(argv[1]);
  const int ny = atoi(argv[2]);
  const int nz = atoi(argv[3]);
  fftx::point_t<3> sz({{nx, ny, nz}});

  int verbosity = 0;
  int rounds = 20;
  if (argc > 4)
    {
      verbosity = atoi(argv[4]);
      if (argc > 5)
        {
          rounds = atoi(argv[5]);
        }
    }
  std::cout << "Running " << sz
            << " with verbosity " << verbosity
            << " and " << rounds << " random rounds"
            << std::endl;

#if FFTX_COMPLEX_TRUNC_LAST
  const int fx = nx;
  const int fy = ny;
  const int fz = nz/2 + 1;
#else
  const int fx = nx/2 + 1;
  const int fy = ny;
  const int fz = nz;
#endif
  
  fftx::box_t<3> domain3(fftx::point_t<3>({{1, 1, 1}}),
                         fftx::point_t<3>({{nx, ny, nz}}));
  fftx::box_t<3> fdomain3(fftx::point_t<3>({{1, 1, 1}}),
                          fftx::point_t<3>({{fx, fy, fz}}));

  /*
    Set up random number generator.
  */
  std::random_device rd;
  generator = std::mt19937(rd());
  unifRealDist = std::uniform_real_distribution<double>(-0.5, 0.5);

  verify3d(domain3, fdomain3, rounds,
           mddft3dDevice, imddft3dDevice,
           mdprdft3dDevice, imdprdft3dDevice,
           verbosity);
#endif  
  printf("%s: All done, exiting\n", argv[0]);
  return 0;
}
