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

TGraphErrors* data_graph();

void peakfit(string runfile) {

    TH1::AddDirectory(kFALSE);

    std::ifstream runs(runfile);
    std::string line;

    TCanvas* c1 = new TCanvas("c1", "PE", 10, 10, 1000, 800);

    TH1F* hpeaks = new TH1F("hpeaks", "Peak Distribution;PE Peak;Counts", 60, 20, 120);

    int runCounter = 0;

    while (std::getline(runs, line)) {
        TFile* f = TFile::Open(line.c_str());
        TH1F* h = (TH1F *)f->Get("hpep");

        int binmax = h->GetMaximumBin();
        double peak = h->GetXaxis()->GetBinCenter(binmax);

        TF1* fitfunc = new TF1("fitfunc", "gaus(0)", peak - 6., peak + 7.);
        fitfunc->SetParameter(0, 1000);
        fitfunc->SetParameter(1, peak);
        fitfunc->SetParameter(2, 100);

        h->Fit("fitfunc", "RBQ0");
        
        h->GetXaxis()->SetRangeUser(0., 150.);
        h->GetYaxis()->SetRangeUser(0., 75000.);
        
        double fitpeak = fitfunc->GetParameter(1);
        hpeaks->Fill(fitpeak);
        
        delete f;
        runCounter++;
    }

    hpeaks->Draw();

    data_graph()->Draw("sames P");
}

TGraphErrors* data_graph() {

    vector<double> x, y, xerr, yerr;
    x.push_back(60.82);
    xerr.push_back(0.95);
    y.push_back(30);
    yerr.push_back(0);

    x.push_back(62.02);
    xerr.push_back(0.73);
    y.push_back(30);
    yerr.push_back(0);

    TGraphErrors* tg = new TGraphErrors( x.size() , &x[0], &y[0],
                                                    &xerr[0], &yerr[0]);

    tg->SetMarkerStyle(20);
    tg->SetMarkerSize(0.8);

    return tg;
}
