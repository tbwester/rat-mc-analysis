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

TGraphErrors* err_pt(double, double, double);
TPolyLine* fill_area(double, double, int);

void peakfit(string runfile) {

    TH1::AddDirectory(kFALSE);

    std::ifstream runs(runfile);
    std::string line;


    TH1F* hpeaks = new TH1F("hpeaks", ";N_{PE};", 20, 20, 120);
    TH1F* hgqe = new TH1F("hpeaks", ";GQE;", 50, 0.02, 0.012);

    while (std::getline(runs, line)) {
        TFile* f = TFile::Open(line.c_str());
        TH1F* h = (TH1F *)f->Get("hpep");
        TH1F* hhit = (TH1F *)f->Get("hhit");

        double hits = hhit->GetMean();

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
        hgqe->Fill(fitpeak / hits);
        
        delete f;
    }

    TCanvas* c1 = new TCanvas("c1", "PE", 10, 10, 1000, 800);
    hpeaks->Scale(1./hpeaks->Integral());
    hpeaks->Draw("hist");

    TCanvas* c2 = new TCanvas("c2", "GQE", 10, 10, 1000, 800);
    hgqe->Scale(1./hgqe->Integral());
    hgqe->SetFillColorAlpha(kRed, 0.5);
    hgqe->Draw("hist");
    


    //err_pt(61.0, 1.0, 0.02)->Draw("sames B");
    //err_pt(62.0, 0.7, 0.021)->Draw("sames B");

    fill_area(61.0, 1.0, kRed)->Draw("sames f");
    //fill_area(62.0, 0.7, kRed)->Draw("sames f");
}

TGraphErrors* err_pt(double x, double err, double y) {
    std::vector<double> px, py, ex, ey;

    px.push_back(x);
    ex.push_back(err);
    py.push_back(y);
    ey.push_back(0);

    TGraphErrors* tg = new TGraphErrors(px.size(), &px[0], &py[0], &ex[0], &ey[0]);

    tg->SetMarkerColor(kRed);
    tg->SetMarkerStyle(20);
    tg->SetMarkerSize(0.5);
    return tg;
}

TPolyLine* fill_area(double x, double err, int col) {
    std::vector<double> px, py;
    
    px.push_back(x - err);
    py.push_back(0.01);
    px.push_back(x - err);
    py.push_back(0.02);
    px.push_back(x + err);
    py.push_back(0.02);
    px.push_back(x + err);
    py.push_back(0.01);
    px.push_back(x - err);
    py.push_back(0.01);

    TPolyLine *pline = new TPolyLine(px.size(), &px[0], &py[0]);

    //pline->SetFillColorAlpha(col, 0.7);
    pline->SetFillColor(col);
    pline->SetFillStyle(1001);

    return pline;
}
