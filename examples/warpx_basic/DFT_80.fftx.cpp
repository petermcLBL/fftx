// make

#include "fftx3.hpp"
#include <array>
#include <cstdio>
#include <cassert>


using namespace fftx;


int main(int argc, char* argv[])
{
  const int l = 80;
  const int m = 80;
  const int n = 80;
  const char* name="DFT_80";
#include "forward.h"

  return 0;
}