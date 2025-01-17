#include <oxstd.oxh>
#import <packages/CATS/CATS>

main()
{
	decl iCont;
    for (iCont = 1; iCont <= 110; ++iCont) {

		// print Headder
        println("\n\n*****************************************");
        println("             Regiao ", iCont);
        println("*****************************************\n\n");

		decl model = new CATS();

		model.Load("C:\\Users\\Teo\\Documents\\GitHub\\Tes_Cap2\\export\\database for ox\\db_oil_forForecast2.csv");
		model.Select("Y", {sprint("R_", iCont, "_ETANOL_HIDRATADO"), 0, 0});
		model.Select("Y", {sprint("R_", iCont, "_OLEO_DIESEL"), 0, 0});
		model.Select("Y", {sprint("R_", iCont, "_GASOLINA_COMUM"), 0, 0});
		model.Select("Y", {"brent", 0, 0});
		model.Select("Y", {"lnCambio", 0, 0});
	//	model.Select("U", {"Constant", 0, 0});

		model.Lags(8,8,8);
		model.I1Rank(1);
		model.Trend("DRIFT");
		model.SetSelSampleByDates(dayofcalendar(2004, 7, 4), dayofcalendar(2021, 8, 29));
		model.SetMethod("RRR");
		model.Estimate();
	
		model.Restrict({"[beta]","[alpha]","* * * 0 0"});
		model.BootstrapRestrictions();
	
		delete model;
	}
}