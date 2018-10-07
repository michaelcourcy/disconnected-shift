Déployer un war dans tomcat sur openshift
Pour déployer un war tomcat sur openshfit le moyen le plus simple que j'ai trouvé est d'utiliser l'image S2I (Source-to-Image) de Sarcouy. Vous verrez dans l'exemple que je présente qu'il n'est pas nécessaire d'utiliser un repository git.

On va donc procéder avec les étapes suivantes :

Créer un projet openshift my-experiences
Creer un projet maven my-app pour faire un war, mais cela peut être votre code existant.
Créer un imagestream tomcat-builder qui embarque le builder de Sarcouy
Creer un imagestream my-tomcat-app qui va recevoir l'image produite par le builder
Creer le builder 
Lancer un build qui va alimenter l'imagestream my-tomcat-app
Créer une application à partir de l'imagestream my-tomcat-app


Creer un projet maven my-app pour faire un war


oc new-project my-experiences
mvn archetype:generate \ 
   -DarchetypeGroupId=org.apache.maven.archetypes \
   -DarchetypeArtifactId=maven-archetype-webapp \
   -DarchetypeVersion=1.3 \
   -DgroupId=fr.maker.paas \
   -DartifactId=my-app \
   -Dversion=1.0-SNAPSHOT 
# verifier que ça construit bien 
cd my-app && mvn package

On crée les imagestream necessaires

oc create imagestream tomcat-builder
oc import-image --from=sarcouy/s2i-tomcat:8.5-jdk8-mvn3.3.9 tomcat-builder
oc create imagestream my-tomcat-app


On crée le builder

On utilisera le paramètre --binary qui nous permet de ne pas utiliser un repo mais de donner en paramètre de lancement le répertoire du code source

#ceci va créer le buidconfig my-tomcat-app qui 
#par défaut récupère le nom de l'imagestream de destination
oc new-build --image-stream=tomcat-builder --binary --to=my-tomcat-app
# le builder de sarcouy nous impose de préciser le nom du war a déployer 
# en variable d'environnement
# je suppose qu'il a du tomber sur des projets qui fabriquaient plusieurs war
# on patch donc le buildconfig 
# vous pourvez aussi utiliser aussi oc edit
oc patch bc my-tomcat-app -p \
  '{ "spec" :{"strategy":{"sourceStrategy":{ "env" : [{"name":"WAR_NAME", "value": "my-app.war"}] } } } }'


On lance le build qui va créer l'image et la mettre dans l'imagestream de destination

oc start-build my-tomcat-app --from-dir=/vagrant/lab/05_builder/tomcat/my-app/ --follow

Ceci construit et pousse l'image dans la registry interne d'openshift, et toute image dans la registry interne est aussi une imagestream. Donc l'image est ici le tag latest de l'imagestream my-tomcat-app.

On déploie
oc new-app --image-stream=my-tomcat-app
#on expose pour la rendre accessible depuis internet
oc expose svc/my-tomcat-app

A chaque fois qu'on relancera un build le deploymentconfig qui référence cet imagestream détectera le changement et redéploiera automatiquement l'image.