#include <iostream>
#include <string>
#include <sstream>
#include <vector>

#include "TCanvas.h"
#include "TNtuple.h"
#include "TH2F.h"
#include "TFile.h"

void platehit() {

    std::vector<std::string> fname = { "PlateHits_r0.root", 
                                       "PlateHits_r150.root",
                                       "PlateHits_r200.root" };

    for (auto&& file : fname) {
        TCanvas* c1 = new TCanvas(file.c_str(), "Plot", 10, 10, 800, 800);
        stringstream filepath;
        filepath << "../rat-mc-far/data/run3000/" << file;

        TFile* f = new TFile(filepath.str().c_str());
        TNtuple* tnp = (TNtuple *)f->Get("dph");

        TH2F* hh = new TH2F("hh", ";x (mm); y (mm)", 80, -160, 160, 80, -160, 160);
        hh->SetMaximum(11.0);
        hh->SetStats(0);
        tnp->Draw("yh:xh>>hh", "", "colz");
    }

}
