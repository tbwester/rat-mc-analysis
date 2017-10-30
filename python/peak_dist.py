import numpy as np
import matplotlib
import matplotlib.pyplot as plt

def peaks(filename):
    peak_list = np.genfromtxt(filename, dtype=float)
    return peak_list

if __name__ == '__main__':
    matplotlib.rcdefaults()
    plt.rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
    plt.rc('text', usetex=False)

    fig = plt.figure(figsize=(6.2, 5))
    ax = fig.add_subplot(111)
    #bins = np.linspace(20, 120, 40)
    bins = np.linspace(8, 45, 30)

    ax.hist(peaks('farpeaks.txt'), bins, alpha=1.0, label='Simulation', fill='b', 
            normed=True, histtype='step', lw=0, color='k')
    
    dat = [(37.5, 0.5), (30.9, 0.5)]
    #dat = [(60.8, 1.0), (62.0, 0.7)]
    for i, pt in enumerate(dat):
        if i == 0:
            ax.axvspan( pt[0] - pt[1], pt[0] + pt[1], alpha=0.5, color='red', label='Data' )
        else:
            ax.axvspan( pt[0] - pt[1], pt[0] + pt[1], alpha=0.5, color='red' )

    #ax.hist(peaks('nearpeaks.txt'), bins, alpha=0.5, label='Near', fill='g', 
    #        normed=True, histtype='step')

    ax.grid('off')
    ax.set_xlabel('$N_{\\rm PE}$', horizontalalignment='right', x=1.0, fontsize=16)
    ax.set_ylabel('Norm. Counts', horizontalalignment='right', y=1.0, fontsize=16)
    plt.legend(loc='best', frameon=False)
    plt.savefig('outpeak.pdf')
