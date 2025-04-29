public class WeatherApiController {
    //this methord returned data from weather api by city name and date 
    public static void getWeatherData(String city,String dt){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:WeatherAPINamedCread/future.json?q='+city+'&dt='+dt);
        req.setMethod('GET');
        HttpResponse res = new HttpResponse();
        Http ht = new Http();
        res=ht.send(req);
        WeatherWrapper wrapper=(WeatherWrapper)JSON.deserialize(res.getBody(),WeatherWrapper.class);
        System.debug(wrapper.location.name);
        System.debug(wrapper.forecast.forecastday[0].day.condition);
    }
    
}