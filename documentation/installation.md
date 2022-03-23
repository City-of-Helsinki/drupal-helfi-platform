Ennen käyttöönottoa
-------------------

Platform vaatii toimiakseen seuraavanlaisen ympäristön:

*   PHP 8 ja Composer 2.x

*   [Docker ja Stonehenge](https://github.com/druidfi/guidelines/blob/master/docs/local_dev_env.md)

  *   Platform pyörii kaikissa ympäristöissä omissa konteissaan Dockerin päällä.

  *   Stonehenge on järjestelmä joka pyrkii tekemään paikallisesta kehittämisestä mahdollisimman yksinkertaista. Se hoitaa reititykset ja paikalliset domainit sekä SSL-sertifikaatit automaattisesti kyseiselle projektille/Drupal instanssille.


Asenna yllä mainitut ohjelmistot ennen platformin käyttöönottoa.

Käyttöönotto
------------

Platformin koodi löytyy [https://github.com/City-of-Helsinki/drupal-helfi-platform](https://github.com/City-of-Helsinki/drupal-helfi-platform). Otathan huomioon että sinun ei tarvitse käydä kloonaamassa koodia käsin missään kohtaa vaan asennukseen käytetään Composeria.

Jos asennuksen aikana esiintyy jotain ongelmia tarkasta ensin kohta “Yleiset ongelmatilanteet” ja jos sieltä ei löydy apua niin ole yhteydessä kehitystiimiin Slackissä kanavalla #helfi-drupal.

1.  **Alusta projekti Composerin avulla.** Korvaa komennosta `HANKKEEN_NIMI` oman hankkeesi nimellä esimerkiksi `helfi_sote`. Composer komento luo kansion `HAKKEEN_NIMI` ja lataa viimeisimmän version platformista kyseiseen kansioon sekä aloittaa git-repositorion.

    `composer create-project City-of-Helsinki/drupal-helfi-platform:dev-main HANKKEEN_NIMI --no-interaction --repository https://repository.drupal.hel.ninja/`

2.  **Siirry kansioon** `HANKKEEN_NIMI` ja muokkaa `.env` tiedostoon `COMPOSE_PROJECT_NAME` ja `DRUPAL_HOSTNAME` oikeat arvot.

3.  **Käynnistä sivuston asennus.** Asennus käyttää Druid Tools [https://github.com/druidfi/tools](https://github.com/druidfi/tools) -komentoja, jotka koostuvat useista drush-komennoista. `make new` käynnistää projektin kontit, ajaa composer installin, asentaa Drupalin, laittaa päälle platformin tukimoduulit, päivittää Drupalin käännökset ja antaa lopulta kirjautumislinkin rakennetulle sivustolle. `make`\-komennoista lisää kohdassa ["Make komentojen käyttäminen projektissa"](https://github.com/City-of-Helsinki/drupal-helfi-platform/wiki/Hel.fi-platform-k%C3%A4ytt%C3%B6%C3%B6notto-hankkeissa#make-komentojen-k%C3%A4ytt%C3%A4minen-projektissa).

    `make new`

4.  **Kirjaudu sisään asennuksen tarjoamasta kirjautumislinkistä ja mene muokkaamaan sivuston tietoja** osoitteissa `https://hankkeen_nimi.docker.so/fi/admin/config/system/site-information` ja `https://hankkeen_nimi.docker.so/fi/admin/tools/site-settings`. Huomaa että paikallisen ympäristösi domain on oman hankkeesi domain. Muista lisätä kieliversiot tiedoista.

5.  Kun sivuston tiedot on tallennettu **vie konfiguraatiot tiedostoihin** ajamalla projektin juuressa `make drush-cex`. Tämä komento ajaa kontissa `drush cex -y` komennon, joka vie tietokantakonfiguraation yaml-tiedostoiksi kansioon `conf/cmi` projektin juuressa.

    `make drush-cex`

6.  **Lisää koodi versionhallintaan.** Varmista että hanketta varten lisätty repositorio Helsingin kaupungin versionhallintaan. Drupal repositoriot tulisi nimetä muotoon `drupal-[hankken_nimi]`.

    `git add .`
    `git commit -m "initial commit"`
    `git branch -M main`
    `git remote add origin git@github.com:City-of-Helsinki/<repositorion_nimi>.git`
    `git push -u origin main`

7.  Jos hankkeelle tulee omia moduuleja ne tulee lisätä `/public/modules/custom` kansion alle. Samoin jos hankkeelle tulee oma teema suositellaan se rakennettavaksi `/public/themes/custom` kansion alta löytyvän `hdbt_subtheme` teeman pohjalta. Tämän teeman base-theme on `/public/themes/contrib` kansion alta löytyvä hdbt-teema [https://github.com/City-of-Helsinki/drupal-hdbt](https://github.com/City-of-Helsinki/drupal-hdbt), joka sisältää Helsingin kaupungin yleisilmeen ja yleisiä toiminnallisuuksia. Tähän hdbt-teemaan ei tulisi tehdä mitään muutoksia vaan kaikki hankekohtainen teemaus tulee tehdä sub-teemaan.

    _Jos haluatte jatkokehittää tai lisätä muutoksia helfi-moduuleihin tai hdbt-teemoihin olettehan yhteydessä helfi-kehitystiimiin Slack kanavalla #helfi-drupal ennen kuin teette mitään muutoksia._


Jatkokehitys hankkeen tarpeisiin
--------------------------------

### Kaikille yleishyödyllisten toiminnallisuuksien kehittäminen ja vieminen platformiin

Repositoriot tulisi nimetä muotoon `drupal-module-helfi-[moduuli_nimi]`.

Tällä hetkellä platform tarjoaa kaikille yhteiseen käyttöön seuraavat moduulit:
[https://github.com/City-of-Helsinki?q=drupal-module&type=&language=&sort=](https://github.com/City-of-Helsinki?q=drupal-module&type=&language=&sort=)

Jos haluat jakaa kehittämäsi moduulin yleiseen käyttöön niin tutustu dokumentaatioon täällä:
Composer repository

### Make-komentojen käyttäminen projektissa

Druid Tools lisää projektiin käyttöön `make` komennon, jonka avulla voi ajaa erilaisia komentoja suoraan konteissa paikalliselta ympäristöltä, mutta komennot toimivat myös kontin sisältä `/app/` kansion alla. Komentamalla pelkän `make` komennon tulostuu ruudulle kaikki komennot, joilla Drupal-instanssia voi komentaa.

Mikäli projektilla ei vielä ole käytössä testi/tuotantoympäristöä mistä hakea tietokannan erilliseen tiedostoon, voi sellaisen luoda lokaalin pohjalta komennolla `make drush-create-dump` . Tämä luo sen hetkisestä tietokannasta `dump.sql` -tiedoston projektin juureen. Käyttäessäsi tätä komentoa sinun tulee kuitenkin varmistua että dump.sql on .gitignore :ssa ettei kanta vahingossa tallennu julkiseen repositorioon.

Ajettaessa `make fresh`Drupal asennetaan projektin juuressa olevaa tietokantatiedostoa käyttäen ja ajettaessa `make new` Drupal asennetaan puhtaana perusasennuksena (`drush si -y --existing-config`).

Ja jos haluaa nähdä, mitä joku tietty komento ajaa, niin `make -n <komento>` näyttää komentosarjan ilman, että komentoa ajetaan.

Platformin toiminnallisuuksien päivitykset
------------------------------------------

Platformiin tulee tasaisin väliajoin päivityksiä ja nämä päivitykset saattavat vaatia manuaalisia toimenpiteitä. Näistä päivityksistä ja tarvittavista toimenpiteistä tiedotetaan Slackissa kanavalla #helfi-drupal. Ohjeet päivitysten tekemiseen löytyvät platformin repositorion [https://github.com/City-of-Helsinki/drupal-helfi-platform/blob/main/CHANGELOG.md](https://github.com/City-of-Helsinki/drupal-helfi-platform/blob/main/CHANGELOG.md) tiedostosta.

Yleiset ongelmatilanteet
------------------------

### Asennus kuolee virheeseen block module not found

Platformin ensimmäinen asennus saattaa joissain tapauksissa kuolla virheeseen “block module not found” ja tähän ongelmaan ratkaisuna toimii vain uudelleen komennon `make new` ajaminen.
