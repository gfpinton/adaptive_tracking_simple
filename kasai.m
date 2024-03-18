function [u] = kasai(Iref,Qref,Idisp,Qdisp,c,fc)

% simple kasai algorithm on demodulated input

kasai_scale = c/fc/2/pi;
u = atan2(Qdisp.*Iref-Qref.*Idisp,Iref.*Idisp+Qref.*Qdisp);
u = u*kasai_scale;
