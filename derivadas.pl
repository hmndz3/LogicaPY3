% =====================================================================
% Derivadas simbolicas en Prolog
%
% derivada(+Expresion, +Variable, -Resultado)
% Devuelve la derivada indicada, SIN simplificar, tal como pide la
% practica. Cada regla de derivacion esta en su propio bloque.
%
% Como se escriben las expresiones:
%   suma x+y   resta x-y   producto x*y   division x/y   potencia x^n
%   sen(x)  cos(x)  tan(x)  arctan(x)  exp(x)  ln(x)
%
% Referencias consultadas:
%   http://www.nivaria.net/blog/index.php/prolog/383-derivada-de-una-funcion-entera
%   https://gist.github.com/tokkenno/8038482
%   http://turing.iimas.unam.mx/~pedroG/al-2008-II/Lab_05.pdf
% =====================================================================


% ------------------------------------------------ derivada de la variable
% La derivada de la propia variable respecto a ella misma vale 1.
derivada(X, X, 1) :- !.


% ------------------------------------------------ derivada de una constante
% Cualquier numero deriva a 0.
derivada(C, _, 0) :- number(C), !.

% Cualquier otro simbolo que no sea la variable tambien deriva a 0.
derivada(A, X, 0) :- atom(A), A \== X, !.


% ------------------------------------------------ menos unario
% d(-u) = -du
derivada(-U, X, -DU) :- !, derivada(U, X, DU).


% ------------------------------------------------ suma
% d(u+v) = du+dv
derivada(U+V, X, DU+DV) :- !, derivada(U, X, DU), derivada(V, X, DV).


% ------------------------------------------------ resta
% d(u-v) = du-dv
derivada(U-V, X, DU-DV) :- !, derivada(U, X, DU), derivada(V, X, DV).


% ------------------------------------------------ producto
% Si uno de los factores es un numero, sale multiplicando: d(c*u) = c*du
derivada(C*U, X, C*DU) :- number(C), !, derivada(U, X, DU).
derivada(U*C, X, DU*C) :- number(C), !, derivada(U, X, DU).

% Caso general: d(u*v) = du*v + u*dv
derivada(U*V, X, DU*V+U*DV) :- !, derivada(U, X, DU), derivada(V, X, DV).


% ------------------------------------------------ division
% d(u/v) = (du*v - u*dv) / v^2
derivada(U/V, X, (DU*V-U*DV)/V^2) :- !, derivada(U, X, DU), derivada(V, X, DV).


% ------------------------------------------------ potencia
% Si la base es la propia variable: d(x^n) = n*x^(n-1)
derivada(X^N, X, N*X^M) :- number(N), !, M is N-1.

% Caso general con regla de la cadena: d(u^n) = n*u^(n-1)*du
derivada(U^N, X, N*U^M*DU) :- number(N), !, M is N-1, derivada(U, X, DU).


% ------------------------------------------------ seno
% d(sen(u)) = cos(u)*du
derivada(sen(U), X, cos(U)*DU) :- !, derivada(U, X, DU).


% ------------------------------------------------ coseno
% d(cos(u)) = -sen(u)*du
derivada(cos(U), X, -sen(U)*DU) :- !, derivada(U, X, DU).


% ------------------------------------------------ tangente
% d(tan(u)) = (1+tan(u)^2)*du
derivada(tan(U), X, (1+tan(U)^2)*DU) :- !, derivada(U, X, DU).


% ------------------------------------------------ arcotangente
% d(arctan(u)) = du / (1+u^2)
derivada(arctan(U), X, DU/(1+U^2)) :- !, derivada(U, X, DU).


% ------------------------------------------------ exponencial
% d(exp(u)) = exp(u)*du
derivada(exp(U), X, exp(U)*DU) :- !, derivada(U, X, DU).


% ------------------------------------------------ logaritmo natural
% d(ln(u)) = du / u
derivada(ln(U), X, DU/U) :- !, derivada(U, X, DU).


% =====================================================================
% Pruebas
% Escribir  pruebas.  en la consola para correrlas todas.
% =====================================================================

% ------------------------------------------------ casos esperados
% caso(Expresion, Variable, ResultadoEsperado)

% Los cinco ejemplos del enunciado
caso(ln(x/(x+1)),        x, (1*(x+1)-x*(1+0))/(x+1)^2/(x/(x+1))).
caso(sen(exp(3*x)),      x, cos(exp(3*x))*(exp(3*x)*(3*1))).
caso(ln(sen((x+1)/x)),   x, cos((x+1)/x)*(((1+0)*x-(x+1)*1)/x^2)/sen((x+1)/x)).
caso((x^5+x^3)/(x^2+1),  x, ((5*x^4+3*x^2)*(x^2+1)-(x^5+x^3)*(2*x^1+0))/(x^2+1)^2).
caso(arctan((x^2+1)^10), x, 10*(x^2+1)^9*(2*x^1+0)/(1+((x^2+1)^10)^2)).

% Casos propios para las funciones que el enunciado no ejemplifica
caso(cos(x^2),           x, -sen(x^2)*(2*x^1)).
caso(tan(x),             x, (1+tan(x)^2)*1).
caso(x^3-x,              x, 3*x^2-1).
caso(x*sen(x),           x, 1*sen(x)+x*(cos(x)*1)).
caso(exp(x)/x,           x, (exp(x)*1*x-exp(x)*1)/x^2).


% ------------------------------------------------ corredor de pruebas
% Corre cada caso, compara contra lo esperado e imprime el resultado.
pruebas :-
    forall(caso(E, V, Esperado), probar(E, V, Esperado)),
    nl,
    aggregate_all(count, caso(_, _, _), Total),
    aggregate_all(count, (caso(E, V, Esp), derivada(E, V, Esp)), Bien),
    format("~w de ~w pruebas correctas~n", [Bien, Total]).

probar(E, V, Esperado) :-
    (   derivada(E, V, R)
    ->  true
    ;   R = sin_resultado
    ),
    (   R == Esperado
    ->  Marca = 'OK   '
    ;   Marca = 'FALLA'
    ),
    format("~w derivada(~w,~w) = ~w~n", [Marca, E, V, R]).
