#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>

#include "TCanvas.h"
#include "TFile.h"
#include "TH1F.h"
#include "TH2F.h"
#include "TF1.h"
#include "TGraphErrors.h"
#include "TPolyLine.h"

void eff(string runfile) {

    TH1::AddDirectory(kFALSE);

    std::ifstream runs(runfile);
    std::string line;

    TH1F* hnorm = new TH1F("hnorm", ";Norm;", 60, 0.1, 0.4);
    TH1F* hsig = new TH1F("hsig", ";sigma;", 60, 60, 100);

    while (std::getline(runs, line)) {
        TFile* f = TFile::Open(line.c_str());
        TGraphErrors* tg = (TGraphErrors *)f->Get("Graph");

        TF1* func = tg->GetFunction("fitfunc");
        
        double norm = func->GetParameter(0);
        double sig = func->GetParameter(2);

        hnorm->Fill(norm);
        hsig->Fill(sig);
        
        std::cout << norm << "\t" << sig << std::endl;

        delete f;
    }

    TCanvas* c1 = new TCanvas("c1", "norm", 10, 10, 1000, 800);
    //hnorm->Scale(1./hnorm->Integral());
    hnorm->Draw("hist");

    TCanvas* c2 = new TCanvas("c2", "sig", 10, 10, 1000, 800);
    //hsig->Scale(1./hsig->Integral());
    hsig->Draw("hist");
    

}
