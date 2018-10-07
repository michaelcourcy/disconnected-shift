#On fait le choix d'une image tomcat qui ne tourne pas en root
FROM cheewai/tomcat
#le dossier dans lequel on veut écrire on l'attribut a tomcat 
RUN mkdir /usr/tomcat/data && chown 1000 /usr/tomcat/data
#VOLUME /usr/tomcat/data
EXPOSE 8080
#on lance le war en le recopiant dans le répertoire webapps
COPY webapp/target/helloworld.war /usr/tomcat/webapps/helloworld.war
