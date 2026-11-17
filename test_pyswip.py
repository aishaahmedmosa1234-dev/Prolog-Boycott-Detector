from pyswip import Prolog

prolog = Prolog()
prolog.consult("boycott.pl")

for r in prolog.query("check_product(coca_cola, S, A, I)"):
    print(r)