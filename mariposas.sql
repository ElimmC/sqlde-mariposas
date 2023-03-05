drop database if exists mariposario;
create database mariposario;

use mariposario;

create table cuentas(
ID_USR int not null primary key,
USR nvarchar(50) not null,
PSSW nvarchar(32) not null
);

create table mariposas(
ID_MAR int not null primary key,
NOMCIE nvarchar(50) not null,
NOMCOM nvarchar(50) not null,
DESCRI nvarchar(400) not null,
ID_TAX nvarchar(100) not null,
IMG nvarchar(200) not null
);

create table localidad(
ID_LUG int not null primary key,
EST int not null,
DELE nvarchar(50) not null
);

create table insectario(
ID_INSE int not null primary key,
NOM_INSE nvarchar(50) not null,
DIREC nvarchar(50) not null,
DIAS_LAB int not null,
INI_INSE nvarchar(50) not null,
FIN_INSE nvarchar(50) not null
);

create table actividades(
ID_ACT int not null primary key,
NOM_ACT nvarchar(100) not null,
DESC_ACT nvarchar(500) not null,
FECHA_R nvarchar(10) not null,
ZONA int not null,
NOM_G nvarchar(50) not null
);

create table rutas(
ID_RUTA int not null primary key,
NOM_RUT nvarchar(50) not null
);

create table puntos(
ID_PUN int not null primary key,
NOM_PUN nvarchar(50) not null,
DIREC nvarchar(200) not null,
DESCRI nvarchar(800) not null,
FEC_PUN nvarchar(50) not null,
HORA nvarchar(50) not null
);

create table viveEn(
ID_MAR int not null ,
ID_LUG int not null ,
foreign key (ID_MAR) references mariposas(ID_MAR),
foreign key (ID_LUG) references localidad(ID_LUG),
primary key (ID_MAR, ID_LUG)
);

create table seCuidan(
ID_MAR int not null ,
ID_INSE int not null ,
foreign key (ID_MAR) references mariposas(ID_MAR),
foreign key (ID_INSE) references insectario(ID_INSE),
primary key (ID_MAR, ID_INSE)
);

create table realizan(
ID_INSE int not null,
ID_ACT int not null,
foreign key (ID_INSE) references insectario(ID_INSE),
foreign key (ID_ACT) references actividades(ID_ACT),
primary key (ID_INSE, ID_ACT)
);

create table forman(
ID_RUTA int not null ,
ID_INSE int not null ,
foreign key (ID_INSE) references insectario(ID_INSE),
foreign key (ID_RUTA) references rutas(ID_RUTA),
primary key (ID_RUTA, ID_INSE)
);

create table tienen(
ID_RUTA int not null,
ID_PUN int not null ,
foreign key (ID_PUN) references puntos(ID_PUN),
foreign key (ID_RUTA) references rutas(ID_RUTA),
primary key (ID_RUTA, ID_PUN)
);

drop procedure if exists spGuardaMariposa;
delimiter **
create procedure spGuardaMariposa(in nomciee nvarchar(50), in nomcom nvarchar(50),in descri nvarchar(400),in idtax int,in imagen nvarchar(200),in locali int)
begin
declare existe int;
declare idMar int;
declare haylugar int;
declare estado int;
declare msj nvarchar(200);
set estado = (select ID_LUG from localidad where EST = locali limit 1);
set haylugar = (select count(*) from localidad where ID_LUG = locali);	
set existe = (select count(*) from mariposas where NOMCIE = nomciee);
    
    if ((existe = 0 or existe=null) and (haylugar = 1))  then
		set idMar = (select ifnull(max(ID_MAR), 0) + 1 from mariposas);
			insert into mariposas (ID_MAR, NOMCIE, NOMCOM, DESCRI, ID_TAX, IMG)
					values(idMar, nomciee, nomcom, descri, idtax, imagen);

			insert into viveEn (ID_MAR, ID_LUG)
					values(idMar, estado);
		set msj =  'Se agregó con éxito';    
    else
		set msj =  'Ya existe la mariposa o no existe el lugar';
    end if;

select msj;

end; **
delimiter ;

drop procedure if exists spEliminaMariposa;
delimiter **
create procedure spEliminaMariposa(in idMar int)
begin
declare existe int;
declare haylugar int;
declare msj nvarchar(200);

set existe = (select count(*) from mariposas where ID_MAR = idMar);
    
    if (existe = 1)  then
			delete from viveEn where ID_MAR = idMar;
			delete from mariposas where ID_MAR = idMar;
		set msj =  'Se eliminó con éxito';    
    else
		set msj =  'No existe la mariposa';
    end if;

select msj;

end; **
delimiter ;

drop procedure if exists spModificaMariposa;
delimiter **
create procedure spModificaMariposa(in marId int, in nomciee nvarchar(50), in nomcom nvarchar(50),in descri nvarchar(400),in idtax int,in imagen nvarchar(200),in locali int)
begin
declare existe int;
declare haylugar int;
declare msj nvarchar(200);

set haylugar = (select count(*) from localidad where ID_LUG = locali);
if(((select count(*) from mariposas where ID_MAR = marId ) = 1) and haylugar = 1) then
        update mariposas set NOMCIE = nomciee , NOMCOM = nomcom ,  DESCRI = descri , ID_TAX = idtax, IMG = imagen where ID_MAR = marId;
        update viveEn set ID_LUG = locali where ID_MAR = marId;	
        set msj =  'Actualizado';
	else
		set msj =  'No se actualizo';
end if;
select msj;

end; **
delimiter ;


drop procedure if exists spGuardaInsectario;
delimiter **
create procedure spGuardaInsectario(in nominse nvarchar(50), in direcc nvarchar(50), in diaslab int,in iniinse nvarchar(50),in fininse nvarchar(50))
begin
declare idInse int;
declare existe int;
declare msj nvarchar(200);

set existe = (select count(*) from insectario where DIREC = direcc and NOM_INSE = nominse);
    
    if (existe = 0)  then
		set idInse = (select ifnull(max(ID_INSE), 0) + 1 from insectario);        
		insert into insectario (ID_INSE, NOM_INSE, DIREC, DIAS_LAB, INI_INSE, FIN_INSE)
					values(idInse, nominse, direcc, diaslab, iniinse, fininse);
		set msj =  'Agregado';        
    else
		set msj =  'Ya existe el insectario';
    end if;


select msj;

end; **
delimiter ;

drop procedure if exists spModificaInsectario;
delimiter **
create procedure spModificaInsectario(in idInse int,in nominse nvarchar(50),in direcc nvarchar(50), in diaslab int,in iniinse nvarchar(50),in fininse nvarchar(50))
begin
declare existe int;
declare msj nvarchar(200);

if((select count(*) from insectario where ID_INSE = idInse ) = 1) then
        update insectario set NOM_INSE = nominse, DIREC = direcc, DIAS_LAB = diaslab , INI_INSE = iniinse ,  FIN_INSE = fininse where ID_INSE = idInse;	
        set msj =  'Actualizado';
    else
		set msj =  'No se ha actualizado';
end if;
select msj;
end; **
delimiter ;

drop procedure if exists spEliminaInsectario;
delimiter **
create procedure spEliminaInsectario(in idInse int)
begin
declare existe int;
declare haylugar int;
declare msj nvarchar(200);

set existe = (select count(*) from insectario where ID_INSE = idInse);
    
    if (existe = 1)  then
			delete from seCuidan where ID_INSE = idInse;
            delete from realizan where ID_INSE = idInse;
			delete from insectario where ID_INSE = idInse;
		set msj =  'Se eliminó con éxito';    
    else
		set msj =  'No existe el insectario';
    end if;

select msj;

end; **
delimiter ;

drop procedure if exists spGuardaMariposaInsectario;
delimiter **
create procedure spGuardaMariposaInsectario(in idMar int, in idInse int)
begin
declare existe int;
declare msj nvarchar(200);
    set existe = (select count(*) from insectario where ID_INSE = idInse);
    if (existe = 0)  then
			insert into viveEn (ID_MAR, ID_INSE)
					values(idMar, idInse);
		set msj =  'Agregado';
        
    else
		set msj =  'Ya existe el insectario';
    end if;
select msj;

end; **
delimiter ;


drop procedure if exists spModificaMariposaInsectario;
delimiter **
create procedure spModificaMariposaInsectario(in idMar int, in idInse int)
begin
declare existe int;
declare msj nvarchar(200);

	if((select count(*) from insectario where ID_INSE = idInse ) = 1) then
			update viveEn set ID_INSE = idInse where ID_MAR = idMar;
        set msj =  'Actualizado';
    else
		set msj =  'No se ha actualizado';
    end if;
    
select msj;

end; **
delimiter ;

drop procedure if exists spGuardaActividad;
delimiter **
create procedure spGuardaActividad(in nombre nvarchar(100), in descri nvarchar(500),in fecha nvarchar(10),in zonaa int,in nomg nvarchar(50))
begin
declare idAct int;
declare existe int;
declare msj nvarchar(200);

set existe = (select count(*) from actividades where NOM_ACT = nombre and DESC_ACT = descri);
    
    if (existe = 0)  then
		set idAct = (select ifnull(max(ID_ACT), 0) + 1 from actividades);        
		insert into actividades (ID_ACT, NOM_ACT, DESC_ACT, FECHA_R, ZONA, NOM_G)
					values(idAct, nombre, descri, fecha, zonaa, nomg);
		set msj =  'Agregado';        
    else
		set msj =  'Ya existe el insectario';
    end if;


select msj;

end; **
delimiter ;

drop procedure if exists spModificaActividad;
delimiter **
create procedure spModificaActividad(in idAct int, in nombre nvarchar(100), in descri nvarchar(500),in fecha nvarchar(10),in zonaa int,in nomg nvarchar(50))
begin
declare existe int;
declare msj nvarchar(200);

if((select count(*) from actividades where ID_ACT = idAct ) = 1) then
        update actividades set NOM_ACT = nombre , DESC_ACT = descri ,  FECHA_R = fecha, ZONA = zonaa, NOM_G = nomg where ID_ACT = idAct;	
        set msj =  'Actualizado';
    else
		set msj =  'No se ha actualizado';
end if;
select msj;
end; **
delimiter ;

drop procedure if exists spGuardaActividadInsectario;
delimiter **
create procedure spGuardaActividadInsectario(in idAct int, in idInse int)
begin
declare existeAct int;
declare msj nvarchar(200);
    set existeAct = (select count(*) from actividades where ID_ACT = idAct);
    if (existeAct = 1)  then
			insert into realizan (ID_INSE, ID_ACT)
					values(idInse, idAct);
		set msj =  'Agregado';
        
    else
		set msj =  'Ya existe la actividad';
    end if;
select msj;

end; **
delimiter ;


drop procedure if exists spModificaActividadInsectario;
delimiter **
create procedure spModificaActividadInsectario(in idAct int, in idInse int)
begin
declare existe int;
declare msj nvarchar(200);

	if((select count(*) from insectario where ID_INSE = idInse ) = 1) then
			update realizan set ID_ACT = idAct where ID_INSE = idInse;
        set msj =  'Actualizado';
    else
		set msj =  'No se ha actualizado';
    end if;
    
select msj;

end; **
delimiter ;

drop procedure if exists spLogin;
delimiter **
create procedure spLogin(in usario nvarchar(50), in psw nvarchar(32))
begin
declare existe int;
declare msj nvarchar(200);

	if((select count(*) from cuentas where USR = usario and PSSW = md5(psw)) = 1) then
        set msj =  'Entra';
    else
		set msj =  'No entra';
    end if;
    
select msj;

end; **
delimiter ;

drop procedure if exists spNuevoUsr;
delimiter **
create procedure spNuevoUsr(in usario nvarchar(50), in psw nvarchar(50))
begin
declare idUsr int;
declare existe int;
declare msj nvarchar(200);

set existe = (select count(*) from cuentas where USR = usario);
    
    if (existe = 0)  then
		set idUsr = (select ifnull(max(ID_USR), 0) + 1 from cuentas);        
		insert into cuentas (ID_USR, USR, PSSW)
					values(idUsr, usario, md5(psw));
		set msj =  'Agregado';        
    else
		set msj =  'Ya existe el usuario';
    end if;
select msj;

end; **
delimiter ;

insert into localidad (ID_LUG, EST, DELE) values(1, 1, "ALVARO OBREGON");
insert into localidad (ID_LUG, EST, DELE) values(2, 1, "AZCAPOTZALCO");
insert into localidad (ID_LUG, EST, DELE) values(3, 2, "ASIENTOS");
insert into localidad (ID_LUG, EST, DELE) values(4, 2, "CALVILLO");
insert into localidad (ID_LUG, EST, DELE) values(5, 3, "ENSENADA");
insert into localidad (ID_LUG, EST, DELE) values(6, 3, "MEXICALI");
insert into localidad (ID_LUG, EST, DELE) values(7, 4, "LORETO");
insert into localidad (ID_LUG, EST, DELE) values(8, 4, "LA PAZ");
insert into localidad (ID_LUG, EST, DELE) values(9, 5, "CARMEN");
insert into localidad (ID_LUG, EST, DELE) values(10, 5, "PALIZADA");
insert into localidad (ID_LUG, EST, DELE) values(11, 6, "ACACOYAGUA");
insert into localidad (ID_LUG, EST, DELE) values(12, 6, "ACALA");
insert into localidad (ID_LUG, EST, DELE) values(13, 7, "AHUMADA");
insert into localidad (ID_LUG, EST, DELE) values(14, 7, "ALDAMA");
insert into localidad (ID_LUG, EST, DELE) values(15, 8, "ABASOLO");
insert into localidad (ID_LUG, EST, DELE) values(16, 8, "ACUÑA");
insert into localidad (ID_LUG, EST, DELE) values(17, 9, "COLIMA");
insert into localidad (ID_LUG, EST, DELE) values(18, 9, "COMALA");
insert into localidad (ID_LUG, EST, DELE) values(19, 10, "CANELAS");
insert into localidad (ID_LUG, EST, DELE) values(20, 10, "DURANGO");
insert into localidad (ID_LUG, EST, DELE) values(21, 11, "CORTAZAR");
insert into localidad (ID_LUG, EST, DELE) values(22, 11, "CELAYA");
insert into localidad (ID_LUG, EST, DELE) values(23, 12, "APAXTLA");
insert into localidad (ID_LUG, EST, DELE) values(24, 12, "ARCELIA");
insert into localidad (ID_LUG, EST, DELE) values(25, 13, "ACTOPAN");
insert into localidad (ID_LUG, EST, DELE) values(26, 13, "APAN");
insert into localidad (ID_LUG, EST, DELE) values(27, 14, "ACATIC");
insert into localidad (ID_LUG, EST, DELE) values(28, 14, "AMACUECA");
insert into localidad (ID_LUG, EST, DELE) values(29, 15, "ACAMBAY");
insert into localidad (ID_LUG, EST, DELE) values(30, 15, "ACOLMAN");
insert into localidad (ID_LUG, EST, DELE) values(31, 16, "ARTEAGA");
insert into localidad (ID_LUG, EST, DELE) values(32, 16, "BUENAVISTA");
insert into localidad (ID_LUG, EST, DELE) values(33, 17, "AYALA");
insert into localidad (ID_LUG, EST, DELE) values(34, 17, "CUERNAVACA");
insert into localidad (ID_LUG, EST, DELE) values(35, 18, "ACAPONETA");
insert into localidad (ID_LUG, EST, DELE) values(36, 18, "COMPOSTELA");
insert into localidad (ID_LUG, EST, DELE) values(37, 19, "ABASOLO");
insert into localidad (ID_LUG, EST, DELE) values(38, 19, "AGUALEGUA");
insert into localidad (ID_LUG, EST, DELE) values(39, 20, "ABEJONES");
insert into localidad (ID_LUG, EST, DELE) values(40, 20, "COSOLAPA");
insert into localidad (ID_LUG, EST, DELE) values(41, 22, "CORREGIDORA");
insert into localidad (ID_LUG, EST, DELE) values(42, 22, "TEQUISQUIAPAN");
insert into localidad (ID_LUG, EST, DELE) values(43, 23, "COZUMEL");
insert into localidad (ID_LUG, EST, DELE) values(44, 23, "TULUM");
insert into localidad (ID_LUG, EST, DELE) values(45, 24, "AHUALULCO");
insert into localidad (ID_LUG, EST, DELE) values(46, 24, "CEDRAL");
insert into localidad (ID_LUG, EST, DELE) values(47, 25, "AHOMA");
insert into localidad (ID_LUG, EST, DELE) values(48, 25, "ANGOSTURA");
insert into localidad (ID_LUG, EST, DELE) values(49, 26, "ACONCHI");
insert into localidad (ID_LUG, EST, DELE) values(50, 27, "COMALCALCO");
insert into localidad (ID_LUG, EST, DELE) values(51, 28, "BURGOS");
insert into localidad (ID_LUG, EST, DELE) values(52, 29, "CALPULALPAN");
insert into localidad (ID_LUG, EST, DELE) values(53, 30, "ACAYUCAN");
insert into localidad (ID_LUG, EST, DELE) values(54, 31, "BACA");
insert into localidad (ID_LUG, EST, DELE) values(55, 32, "APULCO");
insert into localidad (ID_LUG, EST, DELE) values(56, 21, "ACAJETE");

insert into rutas (ID_RUTA, NOM_RUT) values(1, "ORIENTAL");
insert into rutas (ID_RUTA, NOM_RUT) values(2, "OCCIDENTAL");

insert into puntos (ID_PUN, NOM_PUN, DIREC, DESCRI, FEC_PUN, HORA) values(1, "CAÑON DE SANTA ELENA", "Chihuahua, Álamos de San Antonio", 
					"El Área de Protección de Flora y Fauna Cañón de Santa Elena es una zona protegida para la flora y la fauna ubicada en 
					los municipios mexicanos de Manuel Benavides y Ojinaga, en el estado de Chihuahua", "01-09-2021", "06:00");
insert into puntos (ID_PUN, NOM_PUN, DIREC, DESCRI, FEC_PUN, HORA) values(2, "MADERAS DEL CARMEN", "Boquilla del Carmen, Coahuila de Zaragoza", 
					"Área protegida de 208,381 hectáreas que comprende la Sierra del Carmen y la Sierra el Jardín. Declarados Área de protección 
                    de flora y fauna por el entonces presidente Carlos Salinas de Gortari, a fin de preservar los ecosistemas, aprovechar 
                    sustentablemente sus recursos y propiciar su investigación.", 
                    "01-10-2021", "07:00");
insert into puntos (ID_PUN, NOM_PUN, DIREC, DESCRI, FEC_PUN, HORA) values(3, "CUATROCIENAGAS", "Coahuila, Cuatro Cienegas",
					"es considerado el humedal más relevante dentro del desierto chihuahuense y uno de los más destacados en nuestro país. 
                    A nivel mundial está clasificado como un sitio RAMSAR (humedal de importancia internacional)", "01-09-2021", "07:00");
insert into puntos (ID_PUN, NOM_PUN, DIREC, DESCRI, FEC_PUN, HORA) values(4, "SIERRA DE PICACHOS", "Monterrey, Nuevo León", 
					"Es considerada un Área Natural Protegida estatal, una Región Terrestre Prioritaria y un Área de Importancia para la 
                    Conservación de las Aves.", "01-09-2021", "05:00");
insert into puntos (ID_PUN, NOM_PUN, DIREC, DESCRI, FEC_PUN, HORA) values(5, "CHIPINQUE", "Santa Catarina, Nuevo León", 
					"La misión del Parque Ecológico Chipinque es conservar la biodiversidad a través de un manejo integrado que asegure
                    la conservación de sus recursos naturales, que a su vez promueve el respeto y la apreciación, del ecosistema y la geografía del lugar. 
                    El Parque es conocido por su belleza y diversidad de flora y fauna, en donde además, se encuentran pinos, mezquites, cenizos, entre otros.", 
                    "01-09-2021", "05:00");
insert into puntos (ID_PUN, NOM_PUN, DIREC, DESCRI, FEC_PUN, HORA) values(6, "RESERVA DE LA BIOSFERA SIERRA GORDA", "Jalpan de Serra, Queretaro",
					"La Reserva de la Biósfera Sierra Gorda fue creada por decreto presidencial el 19 de mayo de 1997. 
                    La Sierra Gorda fue reconocida por la revista National Geographic Traveler como uno de los sitios con mayor sustentabilidad 
                    turística del mundo. Ocupó el primer sitio de México, el segundo de América latina y el 13 a nivel mundial.", "01-11-2021", 
                    "07:00");
insert into puntos (ID_PUN, NOM_PUN, DIREC, DESCRI, FEC_PUN, HORA) values(7, "PARQUE NACIONAL CUMBRES DE CIMATARIO", "Huimilpan, Queretaro",
					"Este parque nacional, se convirtió en área protegida por decreto, el día 7 de julio de 1982, por ser una porción de territorio
                    representativa de diversos ecosistemas, poseer una gran riqueza biológica e histórica y ser un sitio que produce beneficios
                    ambientales a la región central del país y principalmente a toda el área metropolitana de la ciudad de Querétaro.", "01-11-2021",
					"10:00");
insert into puntos (ID_PUN, NOM_PUN, DIREC, DESCRI, FEC_PUN, HORA) values(8, "SIERRA DE SAN ANDRES", "Hidalgo, Michoacan", 
					" El volcán San Andrés; también llamado “cerro San Andrés”, es un estratovolcán​ que forma parte del Eje Neovolcánico. En algunas 
                    fuentes es referido como 'Sierra de Ucareo'", "01-11-2021", "12:00");

insert into tienen (ID_RUTA, ID_PUN) values(2, 1);
insert into tienen (ID_RUTA, ID_PUN) values(1, 2);
insert into tienen (ID_RUTA, ID_PUN) values(1, 3);
insert into tienen (ID_RUTA, ID_PUN) values(1, 4);
insert into tienen (ID_RUTA, ID_PUN) values(1, 5);
insert into tienen (ID_RUTA, ID_PUN) values(1, 6);
insert into tienen (ID_RUTA, ID_PUN) values(1, 7);
insert into tienen (ID_RUTA, ID_PUN) values(2, 8);

call spGuardaMariposa ("Monarca", "Danaus plexippus", 
					" Las mariposas monarca vuelan aprovechando los vientos del norte a una altura de cien
                    metros, a diferencia de las otras mariposas que vuelan casi al ras del suelo",
                    1, "../img/1.jpeg", 16);
call spGuardaMariposa ("Mariposa de alas largas blanquiazul", "Heliconius sapho", 
					"Una característica interesante de Morpho peleides es que presenta territorialidad, que es 
                    rara o ausente en la mayoría de las especies de mariposas y es quelos machos defienden
                    activamente persiguiendo a los rivales",
                    1, "../img/2.jpeg", 30);
call spGuardaMariposa ("signo de pregunta", "Polygonia interrogationis", 
					"La marca plateada que se encuentra en la parte inferior del ala trasera se divide en dos partes, una
                    línea curva y un punto, que crea una figura en forma de ? que le proporciona el nombre común a esta especie.",
                    1, "../img/3.jpeg", 19);
call spGuardaMariposa ("Mariposa cometa chinanteca", "Pterourus esperanza", 
					"Su distribución está restringida a la Sierra Norte de Oaxaca, en México. Se le encuentra en una zona de 
                    transición de bosque nuboso y bosque de pino; entre 1,600 y 2,500 msnm, con cañones intermitentes.",
                    1, "../img/4.jpeg", 20);
call spGuardaMariposa ("Mariposa búho", "Caligo brasiliensis", 
					"Es una mariposa de la familia Nymphalidae. La especie se puede encontrar en la mayor parte 
                    de América del Sur como varias subespecies, incluidos Brasil, Colombia, Venezuela y Ecuador. 
                    Su área de distribución se extiende a través de Trinidad, Honduras, Guatemala y del norte de Panamá 
                    al sur de México.", 1, "../img/5.jpeg", 27); #xcaret, chapultepec
call spGuardaMariposa ("Mariposa búho magnífico", "Caligo atreus", 
					"Los adultos son conocidos por su vida útil relativamente larga en comparación con otras mariposas.
                    Hasta 3-4 + meses. Los adultos son lentos y a menudo son atacados por aves. Los machos adultos 
                    escarban inactivos la mayor parte del día hasta alrededor de las 6 a.m. y las 6 p.m. durante una
                    hora.", 1, "../img/6.jpg", 6); #xcaret, chapultepec
call spGuardaMariposa ("Mariposa del golfo", "Agraulis vanillae", 
					"Se la distingue de especies similares por las dos manchas plateadas en la célula de las alas
                    delanteras y la forma triangular de las alas traseras; pocas manchas plateadas en la parte inferior
                    de las alas traseras", 1, "../img/7.jpeg", 15); #chapultepec
call spGuardaMariposa ("Macaón de medianoche", "Battus belus", 
					"Se encuentra desde el nivel del mar hasta 1,400 m, asociada con hábitats de bosque lluvioso,
                    raramente en bosque deciduo.", 1, "../img/8.jpeg", 6); #chapultepec
call spGuardaMariposa ("Macaón polydamas", "Battus polydamas", 
					"Se la distingue de todas las demás especies por las manchas submarginales amarillo-verde en
                    las alas anteriores y posteriores.", 1, "../img/9.jpeg", 16); #chapultepec
call spGuardaMariposa ("Zapatera griega", "Catonephele numilia", 
					"Dimorfismo sexual. Macho - se lo distingue por las seis manchas naranja sobre la superficie dorsal.
                     Hembra - se la distingue por la banda media de color crema en las alas anteriores y ninguna banda 
                     en las alas posteriores", 1, "../img/10.jpeg", 30); #chapultepec
call spGuardaMariposa ("Morfo azul", "Morpho helenor", 
					"Se distingue del parecido M. granadensis por tener siempre dos manchas parecidas a la pupila del 
                    ojo en la parte inferior del ala posterior; tiene un colorido azul variante. La parte inferior 
                    siempre se muestra cambiante en cuanto a las manchas oculares.", 1, "img/11.jpeg", 30); #chapultepec
call spGuardaMariposa ("Mariposa Cuatro Espejos", "Cincta rothschildia", 
					"Sus alas son de color chocolate y se caracteriza por poseer grandes espacios traslúcidos en cada
                    ala. Se le distingue de otras especies por el ancho de su banda postmedia (la franja blanca cerca
                    de la mitad de sus alas), la cual está dentada.", 1, "../img/12.jpeg", 26); #yo'o joara

call spGuardaInsectario('Yo’o Joara', 'Cócorit, Sonora',1, '08:00', '16:00');
call spGuardaInsectario('Xcaret', 'Playa del Carmen, Quintana Roo',1, '08:30', '18:00');
call spGuardaInsectario('Mariposario de Chapultepec', 'Chapultepec, Ciudad de México',1, '10:00', '17:00');

call spGuardaMariposaInsectario(4,3);
call spGuardaMariposaInsectario(5,3);
call spGuardaMariposaInsectario(6,3);
call spGuardaMariposaInsectario(7,3);
call spGuardaMariposaInsectario(8,3);
call spGuardaMariposaInsectario(9,3);
call spGuardaMariposaInsectario(10,3);
call spGuardaMariposaInsectario(11,3);
call spGuardaMariposaInsectario(5,2);
call spGuardaMariposaInsectario(6,2);
call spGuardaMariposaInsectario(12,1);

call spGuardaActividad('Libera una mariposa', 'A cada familia (o persona), el Mariposario de Chapultepec
						le entrega una mariposa bebé para que la libere donde están las otras. Antes de
                        liberarla, uno de los guías da una pequeña charla sobre las mariposas que
                        viven en Chapultepec y cómo es que llegan de Costa Rica hasta México.', '31-12-2025', 1, 
                        'José Arruela');
call spGuardaActividad('Apreciacion del cico de vida', 'A la entrada verás una sección dedicada al ciclo de vida
						de las mariposas, que inicia desde que son pequeños huevecillos, pasa por las etapas de
                        larvas y pupas, hasta su metamorfosis final.', '31-12-2025', 1, 
                        'Roberto Tiazin');
call spGuardaActividadInsectario(1,3);
call spGuardaActividadInsectario(2,2);

call spNuevoUsr('elimm', 'corona');
call spLogin('elimm', 'corona');

#1	Ciudad de México	
#2	Aguascalientes	
#3	Baja California	
#4	Baja California Sur	
#5	Campeche	
#6	Chiapas	
#7	Chihuahua	
#8	Coahuila 
#9	Colima	
#10	Durango	
#11	Guanajuato	
#12	Guerrero	
#13	Hidalgo	
#14	Jalisco	
#15	México	
#16	Michoacán 
#17	Morelos	
#18	Nayarit	
#19	Nuevo León	
#20	Oaxaca	
#21	Puebla	
#22	Querétaro Arteaga	
#23	Quintana Roo	
#24	San Luis Potosí	
#25	Sinaloa	
#26	Sonora	
#27	Tabasco	
#28	Tamaulipas	
#29	Tlaxcala	
#30	Veracruz	
#31	Yucatán	
#32	Zacatecas