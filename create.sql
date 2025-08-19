-- 1. Eðer veritabaný varsa sil
IF DB_ID('TelefonOperatorSistemi') IS NOT NULL
BEGIN
    ALTER DATABASE [TelefonOperatorSistemi] SET SINGLE_USER WITH ROLLBACK IMMEDIATE
    USE master
    DROP DATABASE TelefonOperatorSistemi
END
GO

-- 2. Yeni veritabanýný oluþtur
CREATE DATABASE TelefonOperatorSistemi
GO

-- 3. Kullanýlacak veritabaný olarak ayarla
USE TelefonOperatorSistemi
GO

-- 4. Tablolarý doðru sýrada oluþtur
CREATE TABLE Iller (
    IlID INT IDENTITY(1,1) PRIMARY KEY,
    IlIsmi VARCHAR(50) UNIQUE NOT NULL
)
GO

CREATE TABLE Meslekler (
    MeslekID INT IDENTITY(1,1) PRIMARY KEY,
    Meslek_Ad VARCHAR(50) UNIQUE NOT NULL
)
GO

CREATE TABLE Bankalar (
    BankaID INT IDENTITY(1,1) PRIMARY KEY,
    BankaNo CHAR(6) UNIQUE NOT NULL,
    BankaIsmi VARCHAR(100) NOT NULL
)
GO

CREATE TABLE Telefon_Numarasi (
    TelefonNoID INT IDENTITY(1,1) PRIMARY KEY,
    Telefon_No VARCHAR(15),
    Aktif_MI BIT DEFAULT 1 NOT NULL
)
GO

CREATE TABLE OdemeKanallari (
    OdemeKanaliID INT IDENTITY(1,1) PRIMARY KEY,
    OdemeKanaliIsmi VARCHAR(50) UNIQUE NOT NULL
)
GO

CREATE TABLE PaketTurleri (
    PaketTuruID INT IDENTITY(1,1) PRIMARY KEY,
    Isim VARCHAR(100) NOT NULL
)
GO

CREATE TABLE BasvuruTurleri (
    BasvuruTuruID INT IDENTITY(1,1) PRIMARY KEY,
    Isim VARCHAR(100) NOT NULL
)
GO

CREATE TABLE Turler (
    TurID INT IDENTITY(1,1) PRIMARY KEY,
    Isim VARCHAR(100) NOT NULL
)
GO

CREATE TABLE Ilceler (
    IlceID INT IDENTITY(1,1) PRIMARY KEY,
    IlceIsmi VARCHAR(50) UNIQUE NOT NULL,
    IlID INT FOREIGN KEY REFERENCES Iller(IlID) NOT NULL
)
GO

CREATE TABLE SMS (
    Mesaj_No INT PRIMARY KEY,
    Alinma_Tarih_Saat DATETIME,
    Gonderilme_Tarih_Saat DATETIME,
    Kullanilan_SMS_Miktari INT,
    Gonderen_Telefon_No INT FOREIGN KEY REFERENCES Telefon_Numarasi(TelefonNoID),
    Alici_Telefon_No INT FOREIGN KEY REFERENCES Telefon_Numarasi(TelefonNoID)
)
GO

CREATE TABLE Arama (
    Konusma_No INT PRIMARY KEY,
    Arama_Baslangic_Tarih_Saat DATETIME,
    Arama_Bitis_Tarih_Saat DATETIME,
    Arama_Suresi AS DATEDIFF(SECOND, Arama_Baslangic_Tarih_Saat, Arama_Bitis_Tarih_Saat),
    Arayan_Telefon_No INT FOREIGN KEY REFERENCES Telefon_Numarasi(TelefonNoID),
    Aranan_Telefon_No INT FOREIGN KEY REFERENCES Telefon_Numarasi(TelefonNoID)
)
GO

CREATE TABLE TarifePaket (
    TarifePaketID INT IDENTITY(1,1) PRIMARY KEY,
    Aciklama VARCHAR(200),
    Isim VARCHAR(50) NOT NULL,
    BaslangicTarihi DATE NOT NULL,
    BitisTarihi DATE NOT NULL,
    IptalTarihi DATE,
    EnAzBasvuruYasi INT,
    EnCokBasvuruYasi INT,
    EskiAboneAylikFiyat DECIMAL(10,2),
    EskiAboneYillikFiyat DECIMAL(10,2),
    YeniAboneAylikFiyat DECIMAL(10,2),
    YeniAboneYillikFiyat DECIMAL(10,2),
    OtomatikYenileme BIT DEFAULT 0 NOT NULL,
    PaketTuruID INT FOREIGN KEY REFERENCES PaketTurleri(PaketTuruID),
    BasvuruTuruID INT FOREIGN KEY REFERENCES BasvuruTurleri(BasvuruTuruID) NOT NULL,
    TurID INT FOREIGN KEY REFERENCES Turler(TurID) NOT NULL
)
GO

CREATE TABLE Mahalleler (
    MahalleID INT IDENTITY(1,1) PRIMARY KEY,
    MahalleIsmi VARCHAR(50) UNIQUE NOT NULL,
    IlceID INT FOREIGN KEY REFERENCES Ilceler(IlceID) NOT NULL
)
GO

CREATE TABLE CaddeSokak (
    CaddeSokakID INT IDENTITY(1,1) PRIMARY KEY,
    CaddeSokakIsmi VARCHAR(100) UNIQUE NOT NULL,
    MahalleID INT FOREIGN KEY REFERENCES Mahalleler(MahalleID) NOT NULL
)
GO

CREATE TABLE Adresler (
    AdresID INT IDENTITY(1,1) PRIMARY KEY,
    IcKapiNo VARCHAR(10) NOT NULL,
    DisKapiNo VARCHAR(10) NOT NULL,
    AdresAciklama VARCHAR(250),
    IlID INT FOREIGN KEY REFERENCES Iller(IlID) NOT NULL,
    IlceID INT FOREIGN KEY REFERENCES Ilceler(IlceID) NOT NULL,
    MahalleID INT FOREIGN KEY REFERENCES Mahalleler(MahalleID) NOT NULL,
    CaddeSokakID INT FOREIGN KEY REFERENCES CaddeSokak(CaddeSokakID) NOT NULL
)
GO

CREATE TABLE ABONE (
    AboneID INT IDENTITY(1,1) PRIMARY KEY,
    Ad VARCHAR(50) NOT NULL,
    Soyad VARCHAR(50) NOT NULL,
    TCKNo CHAR(11) UNIQUE NOT NULL,
    DogumTarihi DATE NOT NULL,
    Yas AS DATEDIFF(YEAR, DogumTarihi, GETDATE()),
    AktifMi SMALLINT DEFAULT 1 NOT NULL,
    MesleklerID INT FOREIGN KEY REFERENCES Meslekler(MeslekID) NOT NULL,
    AdresID INT FOREIGN KEY REFERENCES Adresler(AdresID) NOT NULL
)
GO

CREATE TABLE Sozlesmeler (
    SozlesmeID INT IDENTITY(1,1) PRIMARY KEY,
    SozlesmeNo VARCHAR(20) UNIQUE NOT NULL,
    BaslangicTarihi DATE NOT NULL,
    BitisTarihi DATE NOT NULL,
    CaymaBedeli DECIMAL(10,2) NOT NULL,
    FaturaTipi VARCHAR(20) CHECK (FaturaTipi IN ('Eposta', 'SMS', 'Basili')) NOT NULL,
    FaturaUstSinir DECIMAL(10,2) NOT NULL,
    AboneID INT NOT NULL FOREIGN KEY REFERENCES ABONE(AboneID),
    BankaID INT FOREIGN KEY REFERENCES Bankalar(BankaID),
    TarifePaketID INT NOT NULL FOREIGN KEY REFERENCES TarifePaket(TarifePaketID),
    TelefonNoID INT FOREIGN KEY REFERENCES Telefon_Numarasi(TelefonNoID),
    SimKartlarID INT, -- FK sonradan eklenecek
    TarifeIsmi VARCHAR(50) NOT NULL,
    TarifeBaslangicTarihi DATE NOT NULL,
    TarifeBitisTarihi DATE NOT NULL,
    TarifeFiyat DECIMAL(10,2) NOT NULL,
    TarifeToplamSMSMiktari INT NOT NULL,
    TarifeToplamKonusmaSuresi INT NOT NULL,
    TarifeToplamInternetMiktariMB INT NOT NULL,
    TarifeKullanilanSMSMiktari INT NOT NULL,
    TarifeKullanilanKonusmaSuresi INT NOT NULL,
    TarifeKullanilanInternetMiktariMB INT NOT NULL,
    TarifeKalanSMSAdedi AS (TarifeToplamSMSMiktari - TarifeKullanilanSMSMiktari),
    TarifeKalanKonusmaSuresi AS (TarifeToplamKonusmaSuresi - TarifeKullanilanKonusmaSuresi),
    TarifeKalanInternetMB AS (TarifeToplamInternetMiktariMB - TarifeKullanilanInternetMiktariMB),
    TarifeIptalEdilmeTarihi DATE
)
GO

CREATE TABLE SimKartlar (
    SimKartID INT IDENTITY(1,1) PRIMARY KEY,
    SeriNo VARCHAR(30) UNIQUE NOT NULL,
    PinKodu CHAR(4) NOT NULL,
    PukKodu CHAR(8) NOT NULL,
    Durum BIT DEFAULT 1 NOT NULL,
    AktifMi BIT DEFAULT 0 NOT NULL,
    SozlesmeID INT -- FK sonradan eklenecek
)
GO

CREATE TABLE InternetKullanim (
    InternetKullanimID INT IDENTITY(1,1) PRIMARY KEY,
    SozlesmeID INT FOREIGN KEY REFERENCES Sozlesmeler(SozlesmeID) NOT NULL,
    BaslangicTarihi DATETIME NOT NULL,
    BitisTarihi DATETIME NOT NULL,
    KullanilanByte BIGINT NOT NULL
)
GO

CREATE TABLE Faturalar (
    FaturaID INT IDENTITY(1,1) PRIMARY KEY,
    FaturaNo VARCHAR(30) UNIQUE NOT NULL,
    Tutar DECIMAL(10,2) NOT NULL,
    FaturaBaslangicTarihi DATE NOT NULL,
    FaturaBitisTarihi DATE NOT NULL,
    FaturaKesimTarihi DATE NOT NULL,
    SonOdemeBaslangicTarihi DATE NOT NULL,
    SonOdemeBitisTarihi DATE NOT NULL,
    OdendigiTarih DATE DEFAULT NULL,
    OdemeKanaliID INT FOREIGN KEY REFERENCES OdemeKanallari(OdemeKanaliID) NOT NULL,
    SozlesmeID INT FOREIGN KEY REFERENCES Sozlesmeler(SozlesmeID) NOT NULL
)
GO

CREATE TABLE SozlesmePaketleri (
    PaketID INT IDENTITY(1,1) PRIMARY KEY,
    Isim VARCHAR(50) NOT NULL,
    BaslangicTarihi DATE NOT NULL,
    BitisTarihi DATE NOT NULL,
    Fiyat DECIMAL(10,2) NOT NULL,
    ToplamSMSMiktari INT NOT NULL,
    ToplamKonusmaSuresi INT NOT NULL,
    ToplamInternetMiktariMB INT NOT NULL,
    KullanilanSMSMiktari INT NOT NULL,
    KullanilanKonusmaSuresi INT NOT NULL,
    KullanilanInternetMiktariMB INT NOT NULL,
    KalanSMSAdedi AS (ToplamSMSMiktari - KullanilanSMSMiktari),
    KalanKonusmaSuresi AS (ToplamKonusmaSuresi - KullanilanKonusmaSuresi),
    KalanInternetMB AS (ToplamInternetMiktariMB - KullanilanInternetMiktariMB),
    IptalEdilmeTarihi DATE,
    SozlesmeID INT FOREIGN KEY REFERENCES Sozlesmeler(SozlesmeID),
    TarifePaketID INT FOREIGN KEY REFERENCES TarifePaket(TarifePaketID)
)
GO

-- 5. Döngüsel foreign key'leri sonradan ekle
ALTER TABLE SimKartlar
ADD CONSTRAINT FK_SimKartlar_Sozlesme
FOREIGN KEY (SozlesmeID) REFERENCES Sozlesmeler(SozlesmeID);
GO

ALTER TABLE Sozlesmeler
ADD CONSTRAINT FK_Sozlesmeler_SimKartlar
FOREIGN KEY (SimKartlarID) REFERENCES SimKartlar(SimKartID);
GO


