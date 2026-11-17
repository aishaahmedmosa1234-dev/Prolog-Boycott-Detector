:- discontiguous product/3, boycotted/1, alternative/2, image/2.

product(mcdonalds,   'McDonald''s',   food).
product(burger_king, 'Burger King',   food).
product(pizza_hut,   'Pizza Hut',     food).
product(papa_johns,  'Papa John''s',  food).
product(nestle,      'Nestle',        food).
product(momen,       'Mo''men',       food).
product(gad,         'Gad',           food).
product(edita_molto, 'Edita Molto',   food).

boycotted(mcdonalds).
boycotted(burger_king).
boycotted(pizza_hut).
boycotted(papa_johns).
boycotted(nestle).            % VERIFY

alternative(mcdonalds,   momen).
alternative(mcdonalds,   gad).
alternative(burger_king, momen).
alternative(burger_king, gad).
alternative(pizza_hut,   gad).
alternative(papa_johns,  gad).
alternative(nestle,      edita_molto).

product(coca_cola,     'Coca-Cola',      drinks).
product(pepsi,         'Pepsi',          drinks).
product(sodastream,    'SodaStream',     drinks).
product(starbucks,     'Starbucks',      drinks).
product(spiro_spathis, 'Spiro Spathis',  drinks).
product(v7,            'V7',             drinks).
product(el_arosa,      'El Arosa Tea',   drinks).
product(abu_auf,       'Abu Auf Coffee', drinks).

boycotted(coca_cola).
boycotted(pepsi).
boycotted(sodastream).
boycotted(starbucks).

alternative(coca_cola,  spiro_spathis).
alternative(coca_cola,  v7).
alternative(pepsi,      spiro_spathis).
alternative(pepsi,      v7).
alternative(sodastream, spiro_spathis).
alternative(starbucks,  abu_auf).
alternative(starbucks,  el_arosa).

product(ariel,   'Ariel',    cleaning).
product(fairy,   'Fairy',    cleaning).
product(omo,     'Omo',      cleaning).
product(sunlight,'Sunlight', cleaning).
product(persil,  'Persil',   cleaning).
product(pril,    'Pril',     cleaning).
product(dixan,   'Dixan',    cleaning).

boycotted(ariel).             % VERIFY
boycotted(fairy).             % VERIFY
boycotted(omo).               % VERIFY
boycotted(sunlight).          % VERIFY

alternative(ariel,    persil).
alternative(ariel,    dixan).
alternative(omo,      persil).
alternative(omo,      dixan).
alternative(fairy,    pril).
alternative(sunlight, pril).

product(puma,        'Puma',        clothes).
product(reebok,      'Reebok',      clothes).
product(zara,        'Zara',        clothes).
product(hm,          'H&M',         clothes).
product(lc_waikiki,  'LC Waikiki',  clothes).
product(defacto,     'DeFacto',     clothes).
product(dice,        'Dice',        clothes).

boycotted(puma).
boycotted(reebok).
boycotted(zara).              % VERIFY
boycotted(hm).                % VERIFY

alternative(puma,   dice).
alternative(puma,   defacto).
alternative(reebok, dice).
alternative(reebok, lc_waikiki).
alternative(zara,   lc_waikiki).
alternative(zara,   defacto).
alternative(hm,     lc_waikiki).
alternative(hm,     defacto).

image(mcdonalds,    'mcdonalds.png').
image(burger_king,  'burger_king.png').
image(pizza_hut,    'pizza_hut.png').
image(papa_johns,   'papa_johns.png').
image(nestle,       'nestle.png').
image(momen,        'momen.png').
image(gad,          'gad.png').
image(edita_molto,  'edita_molto.png').
image(coca_cola,    'coca_cola.png').
image(pepsi,        'pepsi.png').
image(sodastream,   'sodastream.png').
image(starbucks,    'starbucks.png').
image(spiro_spathis,'spiro_spathis.png').
image(v7,           'v7.png').
image(el_arosa,     'el_arosa.png').
image(abu_auf,      'abu_auf.png').
image(ariel,        'ariel.png').
image(fairy,        'fairy.png').
image(omo,          'omo.png').
image(sunlight,     'sunlight.png').
image(persil,       'persil.png').
image(pril,         'pril.png').
image(dixan,        'dixan.png').
image(puma,         'puma.png').
image(reebok,       'reebok.png').
image(zara,         'zara.png').
image(hm,           'hm.png').
image(lc_waikiki,   'lc_waikiki.png').
image(defacto,      'defacto.png').
image(dice,         'dice.png').
product(hohos, 'HOHOS', food).
boycotted(hohos).
image(hohos, 'hohos.png').

