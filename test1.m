%% Calculos 
clear
clc

fs = 48e3;
[Z, P, K] = room('jorge.cmaeso@alumnos.upm.es', 'angela.burgaleta.ledesma@alumnos.upm.es');

%Calculo de H
ceros_fuera = Z(abs(Z) > 1); 
ceros_dentro = Z(abs(Z) < 1);
ceros_compensar = 1./ceros_fuera;
ceros_hmin = [ceros_dentro; ceros_compensar];
polos_hmin = P;
ceros_hap = ceros_fuera;
polos_hap = ceros_compensar;

%Calculo de costantes A->Hmin y B->Hap

a_hmin = prod(-ceros_hap);
b_hap = 1/a_hmin;
k_hc = 1/(a_hmin*K);
%Calculo de funciones en frecuencia

[B_sist, A_sist] = zp2tf(Z,P,K);
[B_hmin, A_hmin] = zp2tf(ceros_hmin,polos_hmin,K*a_hmin);
[B_hap, A_hap] = zp2tf(ceros_hap,polos_hap,b_hap);
[B_hc, A_hc] = zp2tf(polos_hmin,ceros_hmin,k_hc);

[hsist, w] = freqz(B_sist,A_sist,4000);
hmin = freqz(B_hmin,A_hmin,4000);
hap = freqz(B_hap,A_hap,4000);
hc = freqz(B_hc,A_hc,4000);

[B_lpf, A_lpf] = pasobajo(2.2,2500,48e3,3.8);
[B_hpf, A_hpf] = pasoalto(2/3,20e3,48e3,-6);
[B_pbf1, A_pbf1] = pasobanda(2,10000,48e3,0.4);
[B_pbf2, A_pbf2] = pasobanda(1,8000,48e3,1.4);
[B_pbf3, A_pbf3] = pasobanda(1,16000,48e3,-4);

hlpf = freqz(B_lpf,A_lpf,4000);
hpb1 = freqz(B_pbf1,A_pbf1,4000);

bcoefs = [B_lpf;B_pbf1;B_pbf2;B_pbf3;B_hpf];
acoefs = [A_lpf;A_pbf1;A_pbf2;A_pbf3;A_hpf];
hfiltros = concatfilters(bcoefs,acoefs);


%Similitud
hcomp = hfiltros.*hsist;


%% Senales de prueba
[x8, fs8] = audioread('test_8.wav');
[x16, fs16] = audioread('test_16.wav');
[x44, fs44] = audioread('test_44.wav');
%Calculo de cambio de frecuencia fraccionario
[P8, Q8] = rat(fs8/fs);
[P16, Q16] = rat(fs16/fs);
[P44, Q44] = rat(fs44/fs);

% Resample
x81 = resample(x8,P8,Q8,10,100);
x161 = resample(x16,P16,Q16,10,100);
x441 = resample(x44,P44,Q44,10,100);

Y8 = procesar_senal(bcoefs,acoefs,B_sist,A_sist,x81);
Y16 = procesar_senal(bcoefs,acoefs,B_sist,A_sist,x161);
Y44 = procesar_senal(bcoefs,acoefs,B_sist,A_sist,x441);

Ysist = filter(B_sist,A_sist,x441);

figure(1)
spectrogram(x441(:,1), 256, [], [], fs, 'yaxis');
figure(2)
spectrogram(Ysist(:,1), 256, [], [], fs, 'yaxis');
figure(3)
spectrogram(Y44(:,1), 256, [], [], fs, 'yaxis');

%% Representacion
figure(1)
subplot(2,2,1);
zplane(Z,P)
title('H(z)');
subplot(2,2,2);
zplane(ceros_hmin,polos_hmin);
title('Hmin(z)');
subplot(2,2,3);
zplane(ceros_hap,polos_hap);
title('Hap(z)');
subplot(2,2,4);
zplane(polos_hmin,ceros_hmin);
title('Hinv(z)');

%Plot Funciones Interesantes
figure(2)
subplot(2,2,1);
plot(w/pi,abs(hsist))
title('H(z)');
subplot(2,2,2);
plot(w/pi,abs(hmin))
title('Hmin(z)');
subplot(2,2,3);
plot(w/pi,abs(hap))
title('Hap(z)');
subplot(2,2,4);
plot(w/pi,abs(hc))
title('Hinv(z)');

%Plot Funcion a simular
figure(3)
subplot(2,2,1);
plot(w/pi,abs(hc))
title('Hc(z)');
ylabel('Unidades Lineales')
xlabel('w/Pi rad')
subplot(2,2,2);
plot(w/pi,abs(hfiltros))
title('Hfiltros(z)');
ylabel('Unidades Lineales')
xlabel('w/Pi rad')
subplot(2,2,3);
plot(w/pi,20*log10(abs(hc)))
title('Hc(z)');
ylabel('dB')
xlabel('w/Pi rad')
subplot(2,2,4);
plot(w/pi,abs(hc))
plot(w/pi,20*log10(abs(hfiltros)))
title('Hfiltos(z)');
ylabel('dB')
xlabel('w/Pi rad')

%Plot imitar
muestraImitar(hc,hfiltros,w,4);

%Comprovacion hap
figure(5)
subplot(2,1,1);
plot(w/pi,abs(hap))
title('Hap(z)');
ylabel('Unidades Lineales')
xlabel('w/Pi rad')
subplot(2,1,2);
plot(w/pi,abs(hfiltrada))
title('Hresultado(z)');
ylabel('Unidades Lineales')
xlabel('w/Pi rad')

