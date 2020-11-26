use std::fs;
use rustler::{Encoder, Env, Term};
use openapiv3::OpenAPI;

rustler::atoms! {
    ok,
    error,
    not_found,
    parse_error,
    serialize_error
}

enum ParseResult {
    Ok(String),
    NotFound,
    ParseError,
    SerializeError,
}

impl<'a> Encoder for ParseResult {
    fn encode<'b>(&self, env: Env<'b>) -> Term<'b> {
        match self {
            ParseResult::Ok(s) => (ok(), s).encode(env),
            ParseResult::NotFound => (error(), not_found()).encode(env),
            ParseResult::ParseError => (error(), parse_error()).encode(env),
            ParseResult::SerializeError => (error(), serialize_error()).encode(env),
        }
    }
}



#[rustler::nif]
fn to_json(filename: &str) -> ParseResult {

    if let Ok(data) = fs::read_to_string(filename) {
        if let Ok(spec) = serde_yaml::from_str::<OpenAPI>(&data) {
            if let Ok(s) = serde_json::to_string(&spec) {
                return ParseResult::Ok(s);
            }
            return ParseResult::SerializeError;
        }
        return ParseResult::ParseError;

    }
    return ParseResult::NotFound;
}

rustler::init!("Elixir.Quenya.Oas", [to_json]);
