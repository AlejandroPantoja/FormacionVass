/*-------------------------------------------------------------------------------------------------------------------------------------------------------
Author:      Saúl Alarcón Cano
Company:     Deloitte  
Description: Apex Controller/handler del trigger ACP_QuoteAutorizada

History

<Date>          <Author>                 <Description>

21/01/2021    	Saúl Alarcón             Nueva clase que se utilizara para actualizar el estado de las oportunidades
										 relacionadas con las quotes autorizadas
                                         Sergio Perera García cambios
---------------------------------------------------------------------------------------------------------------*/

public class ACP_QuoteAutorizada_Controller {
    /*public static void actualizarEstadoOportunidades(List<NE__Quote__c> quotesAutorizadas){
        // Lista de oportunidades con un booleano para indicar si todas sus quotes están autorizadas
        Map<Id,Boolean> opportunitysIds = new Map<Id,Boolean>();
        for(NE__Quote__c quo : quotesAutorizadas){
            // Se añade si es la primera vez que aparece, o si no es la primera y por el momento todas están autorizadas
            if(!opportunitysIds.containsKey(quo.NE__Opportunity__c) ||
                opportunitysIds.containsKey(quo.NE__Opportunity__c) && opportunitysIds.get(quo.NE__Opportunity__c)){
                   opportunitysIds.put(quo.NE__Opportunity__c, quo.ROS_Aprobaci_n_Comercial_Autorizada__c);
            }
        }
        // Nos quedamos solo con las autorizadas
        List<Id> ids = new List<Id>();
        for(Id i : opportunitysIds.keySet()){
            if(opportunitysIds.get(i)){
                ids.add(i);
            }
        }
        // Se actualizan las oportunidades seleccionadas
        List<Opportunity> opportunitiesToUpdate = [SELECT ID, GE_Finished_Aproval__c FROM Opportunity WHERE Id in :ids];
        for(Opportunity op : opportunitiesToUpdate){
            op.GE_Finished_Aproval__c = true;
            op.ROS_Aprobacion_curso__c = false;
            op.ROS_WF_aprobaci_n_en_curso__c = false;
            op.ROS_WF_autorizaci_n_comercial__c = true;
        }
        update opportunitiesToUpdate;
    }*/
    
   // ACP AHP - I
    // Método para anular las cmp de tipo quote cuando una oferta se ha caducado
    public static void anularCMPyOI(List<NE__Quote__c> OfertasActualizadas){
        if(OfertasActualizadas.size() == 0){return;}
        List<Id> OfertasCaducadas = new List<Id>();
        for (NE__Quote__c Oferta : OfertasActualizadas){
            if ( Oferta.NE__Status__c != null && Oferta.NE__Status__c == 'CADUCADA'){
                OfertasCaducadas.add(Oferta.Id);
            }
        }
		List<Punto_Agrupado__c> CMPsUpdate = [SELECT Id,ROS_Estado__c 
                                              FROM Punto_Agrupado__c 
                                              WHERE ROS_Oferta__c in :OfertasCaducadas 
                                              AND ROS_Estado__c = 'En Negociación'];
        //List<NE__OrderItem__c> OIsUpdate = [SELECT Id,ROS_Estado__c FROM Punto_Agrupado__c WHERE GE_Related_Quote__c in :OfertasCaducadas ];
        //List<Lote__c> LotesOfertas = new List<Lote__c>();
        for(Punto_Agrupado__c cmp : CMPsUpdate){ cmp.ROS_Estado__c = 'Anulado';
        }
        Database.SaveResult[] results = Database.update(CMPsUpdate);
        for (Database.SaveResult r : results){
            if (!r.isSuccess()) {              
                for(Database.Error err : r.getErrors()) {OfertasActualizadas[0].addError(err.getMessage());
                }
            }
        }
    }
    // ACP AHP - F
}