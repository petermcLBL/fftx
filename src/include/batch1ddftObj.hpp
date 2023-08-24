// static constexpr auto batch1ddft_script{
// R"(
//     transform := let(
//         TFCall(TRC(TTensorI(DFT(N, sign), B, read, write)),
//             rec(fname := name, params := []))
//     );
// )"};

std::string batch1ddft_script = "transform := let(\n\
         TFCall(TRC(TTensorI(DFT(N, sign), B, read, write)),\n\
            rec(fname := name, params := [])));";

class BATCH1DDFTProblem: public FFTXProblem {
public:
    using FFTXProblem::FFTXProblem;
    void randomProblemInstance() {
    }
    void semantics() {
        std::cout << "N := " << sizes.at(0) << ";" << std::endl;
        std::cout << "B := " << sizes.at(1) << ";" << std::endl;
        if(sizes.at(2) == 0) {
            std::cout << "read := APar;" << std::endl;
        }
        else{
            std::cout << "read := AVec;" << std::endl;
        }
        if(sizes.at(3) == 0) {
            std::cout << "write := APar;" << std::endl;
        }
        else{
            std::cout << "write := AVec;" << std::endl;
        }
        std::cout << "sign := -1;" << std::endl;
        std::cout << "name := \""<< name << "_spiral" << "\";" << std::endl;
        std::cout << batch1ddft_script << std::endl;
    }
};
