use RegisterCases
go
declare @p1 xml
set @p1=convert(xml,N'<ZL_LIST><ZGLV><VERSION>1.1</VERSION><DATA>2011-10-25</DATA><FILENAME>HRM340062T34_111004</FILENAME></ZGLV><SCHET><CODE>504</CODE><CODE_MO>340062</CODE_MO><YEAR>2011</YEAR><MONTH>10</MONTH><NSCHET>5</NSCHET><DSCHET>2011-10-25</DSCHET><SUMMAV>1849.80</SUMMAV></SCHET><ZAP><N_ZAP>1</N_ZAP><PR_NOV>0</PR_NOV><PACIENT><ID_PAC>4896AD88-5E4F-462C-B1B0-E10F69C34138</ID_PAC><VPOLIS>1</VPOLIS><SPOLIS>347777</SPOLIS><NPOLIS>0011491042</NPOLIS><SMO>34002</SMO><NOVOR>0</NOVOR></PACIENT><SLUCH><IDCASE>1</IDCASE><ID_C>D5FCE817-38E1-4754-A497-988D17B23104</ID_C><USL_OK>2</USL_OK><VIDPOM>1</VIDPOM><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><NHISTORY>6405</NHISTORY><DATE_1>2011-10-16</DATE_1><DATE_2>2011-10-16</DATE_2><DS1>A00.0</DS1><DS2>B15.0</DS2><RSLT>1</RSLT><ISHOD>201</ISHOD><PRVS>1</PRVS><IDSP>6</IDSP><SUMV>308.30</SUMV><USL><IDSERV>1</IDSERV><ID_U>1A65F5DF-6425-4730-A1FB-C2AE30CAB936</ID_U><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><DATE_IN>2011-10-16</DATE_IN><DATE_OUT>2011-10-16</DATE_OUT><DS>A00.0</DS><CODE_USL>55.3.2</CODE_USL><KOL_USL>1.00</KOL_USL><TARIF>308.30</TARIF><SUMV_USL>308.30</SUMV_USL><PRVS>1</PRVS></USL></SLUCH><SLUCH><IDCASE>2</IDCASE><ID_C>7EE9C483-3D35-4DD5-B270-89649304E96B</ID_C><USL_OK>2</USL_OK><VIDPOM>1</VIDPOM><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><NHISTORY>6405</NHISTORY><DATE_1>2011-10-16</DATE_1><DATE_2>2011-10-16</DATE_2><DS1>A00.0</DS1><DS2>B15.0</DS2><RSLT>1</RSLT><ISHOD>201</ISHOD><PRVS>1</PRVS><IDSP>6</IDSP><SUMV>308.30</SUMV><USL><IDSERV>2</IDSERV><ID_U>C094D079-C7F4-4A52-B527-5078F8AC2C25</ID_U><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><DATE_IN>2011-10-16</DATE_IN><DATE_OUT>2011-10-16</DATE_OUT><DS>A00.0</DS><CODE_USL>55.3.2</CODE_USL><KOL_USL>1.00</KOL_USL><TARIF>308.30</TARIF><SUMV_USL>308.30</SUMV_USL><PRVS>1</PRVS></USL></SLUCH><SLUCH><IDCASE>3</IDCASE><ID_C>AA802CC0-5E69-424B-97F4-AD2666C62F7B</ID_C><USL_OK>2</USL_OK><VIDPOM>1</VIDPOM><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><NHISTORY>6405</NHISTORY><DATE_1>2011-10-16</DATE_1><DATE_2>2011-10-16</DATE_2><DS1>A00.0</DS1><DS2>B16.0</DS2><RSLT>1</RSLT><ISHOD>201</ISHOD><PRVS>1</PRVS><IDSP>6</IDSP><SUMV>308.30</SUMV><USL><IDSERV>3</IDSERV><ID_U>3C0BD642-8175-4CBB-B624-370084064E57</ID_U><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><DATE_IN>2011-10-16</DATE_IN><DATE_OUT>2011-10-16</DATE_OUT><DS>A00.0</DS><CODE_USL>55.3.2</CODE_USL><KOL_USL>1.00</KOL_USL><TARIF>308.30</TARIF><SUMV_USL>308.30</SUMV_USL><PRVS>1</PRVS></USL></SLUCH></ZAP><ZAP><N_ZAP>2</N_ZAP><PR_NOV>0</PR_NOV><PACIENT><ID_PAC>AD6547EB-6570-4D0B-BD9A-4FBB3C377C3F</ID_PAC><VPOLIS>1</VPOLIS><SPOLIS>340200</SPOLIS><NPOLIS>7125600297</NPOLIS><SMO>34002</SMO><NOVOR>0</NOVOR></PACIENT><SLUCH><IDCASE>4</IDCASE><ID_C>737CC2FF-9A46-4711-9739-3FAEE0E8E11F</ID_C><USL_OK>2</USL_OK><VIDPOM>1</VIDPOM><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><NHISTORY>31082</NHISTORY><DATE_1>2011-10-16</DATE_1><DATE_2>2011-10-16</DATE_2><DS1>A00.0</DS1><DS2>B15.0</DS2><RSLT>1</RSLT><ISHOD>201</ISHOD><PRVS>1</PRVS><IDSP>6</IDSP><SUMV>308.30</SUMV><USL><IDSERV>4</IDSERV><ID_U>58602CD1-BD91-4AEF-90D7-D93F49E667BB</ID_U><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><DATE_IN>2011-10-16</DATE_IN><DATE_OUT>2011-10-16</DATE_OUT><DS>A00.0</DS><CODE_USL>55.3.2</CODE_USL><KOL_USL>1.00</KOL_USL><TARIF>308.30</TARIF><SUMV_USL>308.30</SUMV_USL><PRVS>1</PRVS></USL></SLUCH></ZAP><ZAP><N_ZAP>3</N_ZAP><PR_NOV>0</PR_NOV><PACIENT><ID_PAC>EEC4691C-154B-4301-927F-BC48FDA03696</ID_PAC><VPOLIS>1</VPOLIS><SPOLIS>340000</SPOLIS><NPOLIS>3455588884</NPOLIS><SMO>34002</SMO><NOVOR>0</NOVOR></PACIENT><SLUCH><IDCASE>5</IDCASE><ID_C>AA2B7958-15CA-40EF-A334-F52F1284CD9D</ID_C><USL_OK>2</USL_OK><VIDPOM>1</VIDPOM><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><NHISTORY>4201</NHISTORY><DATE_1>2011-10-16</DATE_1><DATE_2>2011-10-16</DATE_2><DS1>A00.0</DS1><DS2>B15.0</DS2><RSLT>1</RSLT><ISHOD>201</ISHOD><PRVS>1</PRVS><IDSP>6</IDSP><SUMV>308.30</SUMV><USL><IDSERV>5</IDSERV><ID_U>3ABDF667-F1BE-4585-B80F-62E075EF22DB</ID_U><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><DATE_IN>2011-10-16</DATE_IN><DATE_OUT>2011-10-16</DATE_OUT><DS>A00.0</DS><CODE_USL>55.3.2</CODE_USL><KOL_USL>1.00</KOL_USL><TARIF>308.30</TARIF><SUMV_USL>308.30</SUMV_USL><PRVS>1</PRVS></USL></SLUCH></ZAP><ZAP><N_ZAP>4</N_ZAP><PR_NOV>0</PR_NOV><PACIENT><ID_PAC>3AB1EB23-3978-4D1B-9D97-70DCD39FD306</ID_PAC><VPOLIS>1</VPOLIS><SPOLIS>340198</SPOLIS><NPOLIS>9052300615</NPOLIS><SMO>34002</SMO><NOVOR>0</NOVOR></PACIENT><SLUCH><IDCASE>6</IDCASE><ID_C>EB629A87-3785-496F-BF5A-7FA336565559</ID_C><USL_OK>2</USL_OK><VIDPOM>1</VIDPOM><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><NHISTORY>33495</NHISTORY><DATE_1>2011-10-16</DATE_1><DATE_2>2011-10-16</DATE_2><DS1>A00.0</DS1><DS2>B15.0</DS2><RSLT>1</RSLT><ISHOD>201</ISHOD><PRVS>1</PRVS><IDSP>6</IDSP><SUMV>308.30</SUMV><USL><IDSERV>6</IDSERV><ID_U>62F34051-0213-4FF6-9554-C394CCD204FE</ID_U><LPU>145526</LPU><PROFIL>58</PROFIL><DET>1</DET><DATE_IN>2011-10-16</DATE_IN><DATE_OUT>2011-10-16</DATE_OUT><DS>A00.0</DS><CODE_USL>55.3.2</CODE_USL><KOL_USL>1.00</KOL_USL><TARIF>308.30</TARIF><SUMV_USL>308.30</SUMV_USL><PRVS>1</PRVS></USL></SLUCH></ZAP></ZL_LIST>')
declare @p2 xml
set @p2=convert(xml,N'<PERS_LIST><ZGLV><VERSION>1.1</VERSION><DATA>2011-10-25</DATA><FILENAME>LRM340062T34_111004</FILENAME><FILENAME1>HRM340062T34_111004</FILENAME1></ZGLV><PERS><ID_PAC>4896AD88-5E4F-462C-B1B0-E10F69C34138</ID_PAC><FAM>���������</FAM><IM>�����</IM><OT>��������</OT><W>2</W><DR>2001-02-11</DR><OT_P>���</OT_P><MR>�. ���������</MR><DOCTYPE>14</DOCTYPE><DOCSER>18 04</DOCSER><DOCNUM>627706</DOCNUM><SNILS>111-111-111 11</SNILS></PERS><PERS><ID_PAC>AD6547EB-6570-4D0B-BD9A-4FBB3C377C3F</ID_PAC><FAM>������</FAM><IM>�����</IM><OT>������������</OT><W>1</W><DR>2007-12-06</DR><OT_P>���</OT_P><MR>�. ���������</MR><DOCTYPE>3</DOCTYPE><DOCSER>I-��</DOCSER><DOCNUM>832400</DOCNUM></PERS><PERS><ID_PAC>EEC4691C-154B-4301-927F-BC48FDA03696</ID_PAC><FAM>�������</FAM><IM>������</IM><OT>���������</OT><W>1</W><DR>2011-08-01</DR><FAM_P>��</FAM_P><IM_P>��</IM_P><OT_P>���</OT_P><DR_P>1999-10-19</DR_P><MR>�. ���������</MR><DOCTYPE>14</DOCTYPE><DOCSER>18 06</DOCSER><DOCNUM>923634</DOCNUM><SNILS>222-222-222 22</SNILS></PERS><PERS><ID_PAC>3AB1EB23-3978-4D1B-9D97-70DCD39FD306</ID_PAC><FAM>�������</FAM><IM>�����</IM><OT>����������</OT><W>2</W><DR>1989-05-23</DR><OT_P>���</OT_P><MR>�. ���������</MR><DOCTYPE>14</DOCTYPE><DOCSER>18 03</DOCSER><DOCNUM>871010</DOCNUM></PERS></PERS_LIST>')
exec usp_InsertRegisterCaseDataLPU @doc=@p1,@patient=@p2,@file=0x504B03041400000008000776593F75BCF6D941040000531400001700000048524D3334303036325433345F3131313030342E786D6CED585B6B1B39147E2FF43F94BCCBA3CBD10DD4291A5DD6A6B6C7781C43F3E2876D5902BB296C61BB3F7F8F34E3B499F4212110081BBFE8483A231D7DFA3EE9C8EEC3BF7FFDF9EE9F2F7F7FBBFE7AF3FE822DE8C5BB2F37BF7FFD7C7DF3C7FB8BEFD7379FBF7EFF461897ECE243FBF68DBB5A9FD6ABE1D0BAABDFD6C7D61DD37E58F5DB962D986BCE1517FDC1B79C324618255CBAA636B8BC5AA7ADDFA476B9DF08A054F1838013638C5270CD6DAF6BC6B187B04C3851E8636A65F1A856AD9F367D3B8E30B696BAFB94FCBECEEA9A6ABA4DBF3D2C5B465D335A6E3B0E89014D968B637927D6A96BB8DC6CFCB16506ECC2E018531D8DB1FFCAEF70C4532970C6D170BBFD69DB1F5B749F2CB7F36195B6E8BF8A27B45B3056F9680C91093201C503E958474962342B1B0430615C3339BBE3AE47B8CB0493E586B114A0F187C14CCDDBB1A4B810B08C0202B33D7F3181854DC5741856BF2F218E06867A0E71585F86658934F821954927ABC41EDA2873488669224C6204B404E2C16A628D894C775CB0B249D5D55D0EEB53FFB1C52927CB1D5771D76FEA4A46CBAD77972D0329B9724DB111BC1E49D04A53D0ABA68B88347E520AB75D22F1FAFDA756012D5B78AE16BAA513BBDD44A62AE14AD3D8C5EF77F1B2F5ACF5942E68D9F2E23AF0B66372AC63FF7E58D7B96BE956C3B28F651C5C613531DA63DD985A2242C3AE5565F95816EE1C5B41CD428CC4395644AA57DA1F4764AB55904514BC9259C64C147089C80A4A3CCB1D09DC274183EFACA843A3EBA351ABCB5D6DEF43B0DA4E9DFDE5E17E6F6944487E203409AF2C43CA85589C9557D7F5B15F57038F0F743ED7DCC1EF57F91687B156B1A9DD3FE333FADF85B4A96DCD44CABBDCE4336EEA946C0023888802118C51928E6B4A506C6005856455F7CACD877093CFB819A88548B525416720E025279DE49A48AA4D363EF0500ECD576EFEE0A69871D37B437908144F7C650970E8882D58FAC8955241F1AC5F3E37D5737053CCB82902ED229E99046F25547DE83AD2290E44684A0D500549EAFF3B379B9A97FC94ACF047242B3E2A093A7544493C4CF11C4080A3F50472D78920B40E223F2859A1BC2C7096AC684C2B15E625563F3D5981F9852074083C67623D28BC52719BAC169688EC53A2093318969F4574981519FEA26F0498A94E1A85E75964850A9807FA8420D3A849B422834D4AE9AE7B55DD4C75E211AA4B2980B22C1026F1AE004191BB5C67D2618693A3A74259F530D5D15FA84EE07648833F78BAEAE4BDAB8E77DA4A8391073C252852C30B01244B9E193710A28DCFA23AA8DC7FC1A293F3ABCE7731A3B448665D22200D26B886E28B8127AA65CA9CC757D1CD45078F101D02CC123E6289B0DAE055C7304B8BF8BAD53486286C8E823E5074CC9A7BA2B3547241A962F2E9A25333D125CC79AC37F82ED7C80AB00A4F8A2C3DD119B5A7A442B9DBE7B9EA04D897FDF85133D5616E8E3B2419A19C09CC7AB222564A2041580821720A39BDAAAE08AC39FF31F8F6CD7F504B03041400000008000876593FB2EB5FFE6A02000020050000170000004C524D3334303036325433345F3131313030342E786D6CAD94DF6ADB3014C6EF0B7D87907BD53A922C5BA0AAD896BD1992342459CB76938BB58CC296C20AEB1E6F940D46A1DBDA27F0921A4CD2196FBDD82E069D9C3F4D5B97C2C62E64748E0E87F3FDF4C972E3EDAB97B537BBAF0FF6F607EB7558C3F5DAEEE0F9FECEDEE0C57AFD706FB0B37F788080D850DF50AB2BB21D76BAFD46DCED29F9EC51634BC92D9388375B0AD6405A8B406AAFE72982011060446C694D13328A1B61CB6B86AAD169528631273DCAFA00803193D6F5E9751DA8C70F158292D66C8A722C2563DD6F7B8162AEE09E765D64872C428C9300F9E06314028EB8082803EA4A6B5E2C23AFA9DE7D4DC69717F93031BD4D28E3A67A9F14BFAF4C9589367BEAD3241DE5C36FE6DC04725B11696D1B951DA31103C20481516F4253DB6FAB930F6765A1D9C966478DD66A47F964948F8AE45C5A2621F566D07BDA0E15182D8B7D99EC861D056E0DCFD26554665B4F9A8A13C7C17C9A2E43D96DC58DAE8292EF6CD5CA01665969CD68DC62E2696E3327F411B71D8C98C63EF2B5F0108B7C9F06D471021A5598FC4A874B2067D9C565710DE468929C671759910FB39F0B2870038A633C83A613FF2D145A6512A32FC715242E25C6184B24F7A90EC380710101029BF988517357823811F203E646DAC3940B7E5BF5715EA493FC86ECA36CFC235FEA3E4D8B519ADE2FDADC0476119E3BC134305A3F17D356A5EA78114F371528BA63BE2084289F0C88B2C93F1B88576809423965770D440841F35523E4410351CF87D0271451E1B8C640E023A185831CAC034D45A429BE83F2343BFF3E4EAE96283F1659F982E6244FB2713E49D2FB1E150857206C2342FFE3A3A255073980A1EA206BF98F5B5DF903504B010214001400000008000776593F75BCF6D9410400005314000017000000000000000100200000000000000048524D3334303036325433345F3131313030342E786D6C504B010214001400000008000876593FB2EB5FFE6A020000200500001700000000000000010020000000760400004C524D3334303036325433345F3131313030342E786D6C504B050600000000020002008A000000150700000000