use reqwest::header::{HeaderMap, HeaderValue, HOST, PRAGMA, ACCEPT, AUTHORIZATION, X_XSS_PROTECTION, ACCEPT_LANGUAGE, ACCEPT_ENCODING, CACHE_CONTROL, ORIGIN, USER_AGENT, REFERER};
use reqwest::Client;
use reqwest::header::HeaderName;
use serde_json::{json, Value};
use std::collections::HashMap;
use std::error::Error;
use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    
    let client = Client::new();

    
    let mut headers = HeaderMap::new();
    headers.insert(HOST, HeaderValue::from_static("api-sell.wethenew.com"));
    headers.insert(PRAGMA, HeaderValue::from_static("no-cache"));
    headers.insert(ACCEPT, HeaderValue::from_static("application/json, text/plain, */*"));
    headers.insert(AUTHORIZATION, HeaderValue::from_static("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6ImFsemFyZWltMTIzNEBnbWFpbC5jb20iLCJmaXJzdG5hbWUiOiJJc2FiZWxsZSIsImxhc3RuYW1lIjoiUmVnaW5hYyAiLCJpYXQiOjE2ODkyNDIwODYsImV4cCI6MTY5NDQyNjA4Nn0.ZVF8DOG6a1QJOTbNm07SznkJahGtqNEn2Pez3TmeQwE"));
    headers.insert(X_XSS_PROTECTION, HeaderValue::from_static("1;mode=block"));
    headers.insert(ACCEPT_LANGUAGE, HeaderValue::from_static("fr-FR,fr;q=0.9"));
    headers.insert(ACCEPT_ENCODING, HeaderValue::from_static("gzip, deflate"));
    headers.insert(CACHE_CONTROL, HeaderValue::from_static("no-cache"));
    headers.insert(HeaderName::from_static("feature-policy"), HeaderValue::from_static("microphone 'none'; geolocation 'none'; camera 'none'; payment 'none'; battery 'none'; gyroscope 'none'; accelerometer 'none';"));
    headers.insert(ORIGIN, HeaderValue::from_static("https://sell.wethenew.com"));
    headers.insert(USER_AGENT, HeaderValue::from_static("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"));
    headers.insert(REFERER, HeaderValue::from_static("https://sell.wethenew.com/"));

    let headers_map: HashMap<_, _> = headers.iter().map(|(k, v)| {
        (k.to_string(), v.to_str().unwrap_or("").to_string())
    }).collect();

   
    let proxies = read_lines("./proxies.txt")?
        .map(|line| {
            let line = line?;
            let parts: Vec<&str> = line.split(':').collect();
            if parts.len() == 4 {
                let proxy_url = format!("http://{}:{}@{}:{}", parts[2], parts[3], parts[0], parts[1]);
                Ok(proxy_url)
            } else {
                Err(io::Error::new(io::ErrorKind::InvalidData, "Proxy data is not in the expected format"))
            }
        })
        .collect::<Result<Vec<_>, io::Error>>()?;

    for proxy_url in proxies {
        let payload = json!({
            "headers": headers_map.clone(),
            "requestUrl": "https://api-sell.wethenew.com/consignment-slots?productBrands%5B%5D=Nike&productBrands%5B%5D=Adidas&productBrands%5B%5D=Air%20Jordan&productBrands%5B%5D=New%20Balance&productBrands%5B%5D=Swatch&skip=0&take=100",
            "requestMethod": "GET",
            "proxyUrl": proxy_url,
        });

        let res = client.post("http://localhost:8080/api/forward")
            .header("x-api-key", "my-auth-key-1")
            .json(&payload)
            .send()
            .await?;

        let res_text = res.text().await?;

        let value: Value = serde_json::from_str(&res_text)?;

        if let Some(body) = value.get("body") {
            println!("{}", body);
        } else {
            println!("No'body' hehe");
        }
    }

    Ok(())
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>> where P: AsRef<Path> {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}
