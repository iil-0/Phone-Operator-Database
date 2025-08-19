SELECT 
    i.IlIsmi, 
    COUNT(DISTINCT a.AboneID) AS AboneSayisi     
FROM ABONE a                                     
JOIN Adresler adr ON a.AdresID = adr.AdresID     
JOIN Iller i ON adr.IlID = i.IlID                
JOIN Sozlesmeler s ON s.AboneID = a.AboneID      
JOIN SozlesmePaketleri sp ON sp.SozlesmeID = s.SozlesmeID 
WHERE 
    a.AboneID IN (
        SELECT a2.AboneID
        FROM ABONE a2
        JOIN Sozlesmeler s2 ON s2.AboneID = a2.AboneID
        JOIN Arama ar ON ar.Arayan_Telefon_No = s2.TelefonNoID
        WHERE 
            MONTH(ar.Arama_Baslangic_Tarih_Saat) = MONTH(GETDATE()) 
            AND YEAR(ar.Arama_Baslangic_Tarih_Saat) = YEAR(GETDATE())
        GROUP BY a2.AboneID
        HAVING SUM(DATEDIFF(SECOND, ar.Arama_Baslangic_Tarih_Saat, ar.Arama_Bitis_Tarih_Saat)) >
        (
            SELECT AVG(DATEDIFF(SECOND, ar2.Arama_Baslangic_Tarih_Saat, ar2.Arama_Bitis_Tarih_Saat))
            FROM Arama ar2
            JOIN Sozlesmeler s3 ON s3.TelefonNoID = ar2.Arayan_Telefon_No
            JOIN ABONE a3 ON a3.AboneID = s3.AboneID
            WHERE 
                MONTH(ar2.Arama_Baslangic_Tarih_Saat) = MONTH(DATEADD(YEAR, -1, GETDATE()))
                AND YEAR(ar2.Arama_Baslangic_Tarih_Saat) = YEAR(DATEADD(YEAR, -1, GETDATE()))
        )
    )
GROUP BY i.IlIsmi
HAVING COUNT(DISTINCT a.AboneID) > 1000
ORDER BY 
    CASE 
        WHEN LEFT(i.IlIsmi, 1) = 'A' THEN 0
        ELSE 1
    END,
    CASE 
        WHEN LEFT(i.IlIsmi, 1) = 'A' THEN i.IlIsmi
        ELSE NULL
    END ASC,
    CASE 
        WHEN LEFT(i.IlIsmi, 1) <> 'A' THEN COUNT(DISTINCT a.AboneID)
        ELSE NULL
    END DESC

-- Diger select sorgusu.
SELECT 
    a.AboneID,  
    s.SozlesmeID,  
    s.TarifeIsmi,  
    s.TarifeKalanInternetMB  
FROM ABONE a
JOIN Sozlesmeler s ON s.AboneID = a.AboneID
WHERE s.BitisTarihi > GETDATE()  
AND NOT EXISTS (  
    SELECT TOP 1 1
    FROM (
        SELECT TOP 3 sp2.TarifePaketID
        FROM ABONE a2
        JOIN Sozlesmeler s2 ON s2.AboneID = a2.AboneID
        JOIN SozlesmePaketleri sp2 ON sp2.SozlesmeID = s2.SozlesmeID
        WHERE ABS(DATEDIFF(YEAR, a.DogumTarihi, a2.DogumTarihi)) <= 3  
        GROUP BY sp2.TarifePaketID
        ORDER BY COUNT(*) DESC
    ) AS EnPopuler
    WHERE NOT EXISTS (
        SELECT 1
        FROM Sozlesmeler s3
        JOIN SozlesmePaketleri sp3 ON sp3.SozlesmeID = s3.SozlesmeID
        WHERE s3.AboneID = a.AboneID
        AND sp3.TarifePaketID = EnPopuler.TarifePaketID  
    )
)

