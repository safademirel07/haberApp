# flutter-haberapp
günlük gazetelerden haberler


#Kurulum ve çalıştırma

1. https://nodejs.org/en/download/ NodeJs'i indirip kuralım. 
2. cmd açalım, "cd haber-api" ile klasörün içine girelim.
3. cmd'de "npm install" yazıp bekleyelim.
4. bir hata vermezse

added 492 packages from 440 contributors and audited 495 packages in 28.578s

14 packages are looking for funding
  run `npm fund` for details

found 0 vulnerabilities

şeklinde yazı yazıyor.

5. node src/index.js yazıp çalıştıralım. Hata vermezse Server is up on port 3000 yazacaktır.

6. flutter-haberapp\haber\lib\data klasörünün içinde constants.dart dosyasını açalım.

7.1.static const String api_url  satırını bulup içerdeki ip adresinizi, kendi local ip adresinizle değiştirin örneğin http://192.168.31.223:3000 

veya benim kurduğum sunucuya erişmek isterseniz,

7.2. constants.dart içinde api_url'i şu şekilde değiştirin http://138.68.95.80:3000 

