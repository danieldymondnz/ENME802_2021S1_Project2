clear 
t = [0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0];
for I = 1:11
    J0(I) = (1-t(I))^3;
    
end 
plot(t,J0,'r','LineWidth',3)
xlabel('t');
ylabel('J');
hold on

for I =1:11
    J1(I) = 3*t(I)*(1-t(I))^2;
end 
plot(t,J1,'g','LineWidth',3)
xlabel('t');
ylabel('J');
hold on

for I =1:11
    J2(I) = 3*t(I)^2*(1-t(I));
end  
plot(t,J2,'m','LineWidth',3)
xlabel('t');
ylabel('J');
hold on

for I =1:11
    J3(I) = t(I)^3;
end 
plot(t,J3,'b','LineWidth',3)
xlabel('t');
ylabel('J');
hold on

