import numpy as np
import matplotlib
import matplotlib.pyplot as plt

def gqes(filename):
    gqe_list = np.genfromtxt(filename, dtype=float)
    return gqe_list

if __name__ == '__main__':
    matplotlib.rcdefaults()
    plt.rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
    plt.rc('text', usetex=False)

    fig = plt.figure(figsize=(8, 5))
    ax = fig.add_subplot(111)
    bins = np.linspace(0, 0.014, 40)

    ax.hist(gqes('fargqe.txt'), bins, alpha=0.5, label='Far', fill='b', 
            normed=True, histtype='step', lw=0)
    ax.hist(gqes('neargqe.txt'), bins, alpha=0.5, label='Near', fill='g', 
            normed=True, histtype='step', lw=0)

    ax.grid('off')
    ax.set_xlabel('GQE')
    ax.set_ylabel('Counts (arb.)')
    plt.legend(loc='best', frameon=False)
    plt.savefig('out.pdf')
