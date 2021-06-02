USE DoctorsExperts
GO

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
grant select on object::t_Organization to db_DoctorsExperts
grant select on object::sprCause to db_DoctorsExperts
grant select on object::t_Exclusion to db_DoctorsExperts
grant select on object::t_Qualification to db_DoctorsExperts
grant select on object::sprAcademicDegree to db_DoctorsExperts
grant select on object::t_AcademicDegree to db_DoctorsExperts
grant select on object::t_Documentation to db_DoctorsExperts
grant select on object::vw_ListDoctorsExperts to db_DoctorsExperts
grant select on object::t_FileExists to db_DoctorsExperts
grant select on object::vw_Qualification to db_DoctorsExperts
grant select on object::sprOrganizationType to db_DoctorsExperts
grant select on object::vw_AcademicDegree to db_DoctorsExperts
grant select on object::vw_sprOrganizationType to db_DoctorsExperts
grant select on object::vw_sprQualification to db_DoctorsExperts
grant select on object::vw_DoctorsReport to db_DoctorsExperts
grant select on object::AcademicDegree to db_DoctorsExperts
grant select on object::vw_DoctorsExpert to db_DoctorsExperts
grant select on object::IdentityCard to db_DoctorsExperts
grant select on object::vw_Sex to db_DoctorsExperts
grant select on object::t_Certification to db_DoctorsExperts
grant select on object::t_Files to db_DoctorsExperts
grant select on object::vw_AllInformationAboutDoctorsExpert to db_DoctorsExperts
grant select on object::t_TestApp to db_DoctorsExperts
grant select on object::vw_DoctorExpertAll to db_DoctorsExperts
grant select on object::vw_Certification to db_DoctorsExperts
grant select on object::sysdiagrams to db_DoctorsExperts
grant select on object::vw_sprCause to db_DoctorsExperts
grant select on object::t_DoctorsExperts to db_DoctorsExperts


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------
grant insert on object::t_Organization to db_DoctorsExperts
grant insert on object::sprCause to db_DoctorsExperts
grant insert on object::t_Exclusion to db_DoctorsExperts
grant insert on object::t_Qualification to db_DoctorsExperts
grant insert on object::sprAcademicDegree to db_DoctorsExperts
grant insert on object::t_AcademicDegree to db_DoctorsExperts
grant insert on object::t_Documentation to db_DoctorsExperts
grant insert on object::t_FileExists to db_DoctorsExperts
grant insert on object::sprOrganizationType to db_DoctorsExperts
grant insert on object::t_Certification to db_DoctorsExperts
grant insert on object::t_Files to db_DoctorsExperts
grant insert on object::t_TestApp to db_DoctorsExperts
grant insert on object::sysdiagrams to db_DoctorsExperts
grant insert on object::t_DoctorsExperts to db_DoctorsExperts


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

grant execute on object::usp_LoadXML to db_DoctorsExperts
grant execute on object::XmlCharReplace to db_DoctorsExperts

grant execute on object::usp_CheckUniqueDocCode to db_DoctorsExperts
grant execute on object::usp_ReportCertification to db_DoctorsExperts
grant execute on object::usp_DoctorsReportExclusion to db_DoctorsExperts
grant execute on object::usp_DoctorsReportExclusionPeriod to db_DoctorsExperts

grant execute on object::usp_AddNewDoctors to db_DoctorsExperts
grant execute on object::usp_UpdateDoctorData to db_DoctorsExperts
grant execute on object::usp_UpdateGetDoctorData to db_DoctorsExperts
grant execute on object::fn_diagramobjects to db_DoctorsExperts
grant execute on object::GetOrgan to db_DoctorsExperts
grant execute on object::usp_ExclusionDoctor to db_DoctorsExperts