========================================================
Klaster obliczeniowy Distributed Computing Cluster (DCC)
========================================================

.. highlight:: console

Sprzęt
======

W skład klastra wchodzi 16 (raczej wiekowych) serwerów Dell (partycja ``dcc``) oraz 6 całkiem nowych
serwerów Intela (partycja ``pmem``).


Partycja dcc
------------

Komputery ``dcc-1`` do ``dcc-10`` to `Dell PowerEdge 860
<https://www.dell.com/support/home/pl-pl/product-support/product/poweredge-860/>`_, komputery
``dcc-11`` do ``dcc-16`` to `PowerEdge R200
<https://www.dell.com/support/home/pl-pl/product-support/product/poweredge-r200/>`_.  Oto podstawowe
dane o konfiguracji tych komputerów:

PowerEdge 860
  * CPU: 1x Intel Xeon X3230 @ 2.66 GHz, 2 rdzenie z hyperthreading (logiczne 4 węzły)
  * RAM: 4 GiB

PowerEdge R200
  * CPU: Intel Xeon L3360 @ 2.83 GHz, 2 rdzenie z hyperthreading
  * RAM: 8 GiB

Partycja pmem
-------------

W skład partycji ``pmem`` wchodzi 6 serwerów Intela z trwałą pamięcią *pmem*.  Węzły nazywają się
``pmem-1`` do ``pmem-6``.  Ich konfiguracja jest następująca:

* CPU: 2×Intel Xeon Gold 6252N @ 3.6 GHz, 24 rdzenie z hyperthreading
  (łącznie 96 rdzeni logicznych)
* RAM: 192 GiB


Architektura
============

Węzły obliczeniowe ``dcc-1``, ``dcc-2``, ... ``dcc-16`` to fizyczne komputery z przypisanymi
adresami prywatnymi.  Należy się najpierw zalogować do węzła ``slurm.cs.put.poznan.pl`` a następnie
można inicjować przetwarzanie na poszczególnych węzłach.  Architektura wygląda więc następująco::

    .---------.                .---------.
    |  dcc-1  |      . . .     |  dcc-16 |
    `---------'                `---------'
         |                          |
         `-------.          .-------'
                .------------.
                | switch 1Gb |
                `------------'
             ,-----'      `-------.
             |                    |
         .--------.      .--------------------.
         |  NFS   |      |  Kontroler SLURM   |
         | server |      `--------------------'
         `--------'

Węzeł ``slurm`` jest zawsze dostępny.  Węzły obliczeniowe partycji ``dcc`` są automatycznie
wyłączane po 30 minutach bezczynności w celu ograniczenia zużycia prądu.  Włączanie komputerów z
reguły trwa poniżej 3 minut.

Na każdym z komputerów jest dostępny lokalny, duży katalog ``/data`` o prawach
dostępu takich jak katalog ``/tmp``. Można go wykorzystać do przechowywania
danych wejściowych i wyników eksperymentów obliczeniowych.


Użytkowanie
===========

Do zarządzania klastrem obliczeniowym wykorzystywany jest system `SLURM
<https://slurm.schedmd.com/>`_ (Simple Linux Utility for Resource Management).

1. Logujemy się na swoje konto LDAP do serwera dostępowego ``slurm``.  Po zalogowaniu widoczny jest
   katalog domowy zasobów obliczeniowych, zarówno na węźle zarządzającym jak i na węzłach roboczych.
   Standardowy katalog domowy użytkownika jest podstępny pod ścieżką ``/sirius/USER``.

2. Do pracy interaktywnej wykonujemy alokację węzłów komendą ``salloc``, np.::

     $ salloc -p dcc -N 8

   gdzie ``-p dcc`` wskazuje na partycję zasobów obliczeniowych, a ``-N 8`` oznacza liczbę węzłów do
   zaalokowania.  Można zaalokować konkretne maszyny, np.::

     $ salloc -p pmem -w "pmem-[4-6]"

   Wykonanie alokacji jest konieczne do zalogowania się na węzły obliczeniowe.  Na wypadek dłuższego
   oczekiwania można zastosować powiadamianie email-em::

     $ salloc -p dcc -N 16 --mail-type=BEGIN --mail-user=voytek@example.com

3. Do interaktywnego uruchomienia obliczeń używamy komendy ``srun``, np.::

     $ srun -p dcc -N 2 CMD ARGS

4. Zlecenie można też przekazać w postaci wsadowej komendą ``sbatch``, np.::

     $ sbatch -p dcc -N 4 skrypt.sh

5. Kolejkę realizowanych zadań można obejrzeć komendą ``squeue``::

     $ squeue -p dcc
        JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
           58       dcc hostname   voytek PD       0:00     16 (Resources)
           57       dcc     bash    basia  R    7:07:21     16 dcc-[1-16]

   Z prezentowanych informacji widać kto i od kiedy zajmuje klaster.

6. Anulowanie (własnych) zadań umożliwia komenda ``scancel``::

     $ scancel 57

7. Stan klastra można zbadać komendą ``sinfo``.  Stan ze znakiem ``~`` na końcu oznacza wyłączenie
   zasilania.  Stan ze znakiem ``#`` na końcu pojawia się podczas włączania serwera.

Więcej informacji dotyczących SLURM można znaleźć w dokumentacji
http://slurm.schedmd.com/quickstart.html.

Owocnych obliczeń!
