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
#include "TGraph.h"

int linecount(string file);

void peakfit(string runfile) {

    std::ifstream runs(runfile);
    std::string line;

    std::ofstream datafile("peaks.txt");
    std::stringstream outstream;

    TCanvas* c1 = new TCanvas("c1", "PE Spectra", 10, 10, 1000, 800);

    c1->Divide(2,2,0.002,0.002);
    c1->cd(1);
    TH1F* hpeaks = new TH1F("hpeaks", "Peak Distribution;PE Peak;Counts", 60, 20, 120);
    TH1F* hhits = new TH1F("hhits", "Plate Hit Distribution;Hits;Counts", 100, 4000, 14000);
    TH2F* hgqe = new TH2F("hgqe", ";Peak Position (PE);Plate Hits", 60, 20, 120, 60, 4000, 14000);
    TH2F* hgqe2 = new TH2F("hgqe2", ";Peak Position (PE);GQE", 60, 20, 120, 60, 0.002, 0.015);
    hgqe->SetStats(kFALSE);
    hgqe2->SetStats(kFALSE);

    std::vector<double> x, y, ytemp, gqes;
    std::vector<TH1F *> hlist;


    int runCounter = 0;

    while (std::getline(runs, line)) {
        TFile* f = TFile::Open(line.c_str());
        TH1F* hhit = (TH1F *)f->Get("hhit");
        TH1F* h = (TH1F *)f->Get("hpep");

        int binmax = h->GetMaximumBin();
        double peak = h->GetXaxis()->GetBinCenter(binmax);

        TF1* fitfunc = new TF1("fitfunc", "gaus(0)", peak - 6., peak + 7.);
        fitfunc->SetParameter(0, 1000);
        fitfunc->SetParameter(1, peak);
        fitfunc->SetParameter(2, 100);

        h->Fit("fitfunc", "RBQ0");
        
        // Drawing
        h->UseCurrentStyle(); // overwrite style from file
        h->SetStats(kFALSE);
        
        h->GetXaxis()->SetRangeUser(0., 150.);
        h->GetYaxis()->SetRangeUser(0., 75000.);
        runCounter == 0 ? h->Draw("hist") : h->Draw("hists same");
        
        // Data
        double fitpeak = fitfunc->GetParameter(1);
        double hitmean = hhit->GetMean();
        hpeaks->Fill(fitpeak);
        gqes.push_back(fitpeak / hitmean);

        hgqe2->Fill(fitpeak, fitpeak / hitmean);

        hhits->Fill(hitmean);
        hgqe->Fill(fitpeak, hitmean);

        outstream << line << "\t" 
                  << fitpeak << "\t"
                  << hitmean 
                  << std::endl;

        x.push_back(fitpeak);
        ytemp.push_back(fitpeak - 74.1);

        hlist.push_back(h); 
        //f->Close();       
        runCounter++;
    }

    datafile << outstream.str() << std::endl;

    // Color histograms
    double minpeak = *std::min_element(x.begin(), x.end());
    double maxpeak = *std::max_element(x.begin(), x.end());
    for (auto i = 0; i != hlist.size(); i++) {
        hlist[i]->SetLineColor( gStyle->GetColorPalette(
                    (x[i] - minpeak) / (maxpeak - minpeak) * 998 ));
    }
        
    // Peak histogram
    c1->cd(2);
    hpeaks->Draw();

    // Graph
    c1->cd(3);
    hgqe2->Draw("colz");
#if 0
    std::sort(x.begin(), x.end());
    std::sort(ytemp.begin(), ytemp.end());
    for (unsigned int i = 0; i != ytemp.size(); i++) {
        y.push_back(ytemp[i] * ytemp[i] / 74.1);
    }
    TGraph* gr = new TGraph(runCounter, &x[0], &y[0]);
    gr->SetTitle("#chi^{2};Peak Position;#chi^{2}");
    gr->SetMarkerStyle(2);
    gr->GetYaxis()->SetRangeUser(-2., 20.);
    gr->Draw();
#else
    //TGraph* gr = new TGraph(runCounter, &x[0], &gqes[0]); 
    //gr->SetTitle(";Peak Position;GQE");
    //gr->SetMarkerStyle(20);
    //gr->SetMarkerSize(0.6);
    //gr->Draw("AP");
#endif

    // Hits vs. peak 2d hist
    c1->cd(4);
    hgqe->Draw("colz");
    
    //std::cout << hgqe->GetMean() << std::endl;
    c1->Draw();

}

int linecount(string file) {

    std::ifstream ifile(file);
    std::string line;

    int runCounter = 0;

    while (std::getline(ifile, line)) {
        runCounter++;
    }
    
    return runCounter;
}
