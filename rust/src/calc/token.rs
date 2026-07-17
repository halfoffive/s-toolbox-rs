// Token 定义与词法分析
// 纯函数 tokenize：&str -> Result<Vec<Token>, String>，无副作用

/// 计算器支持的词法单元
///
/// 一元正负号不在词法层区分，交给 parser 依据位置判断
#[derive(Debug, Clone, PartialEq)]
pub enum Token {
    Num(f64), // 数字字面量
    Plus,     // +
    Minus,    // -
    Star,     // *
    Slash,    // /
    Percent,  // %（后缀单目：把左边值 / 100）
    LParen,   // (
    RParen,   // )
}

/// 将源字符串切分为 Token 序列
///
/// 空白字符跳过；连续数字（含单个小数点）聚合成 Num
pub fn tokenize(input: &str) -> Result<Vec<Token>, String> {
    let mut tokens: Vec<Token> = Vec::new();
    let chars: Vec<char> = input.chars().collect();
    let mut i = 0;
    while i < chars.len() {
        let c = chars[i];
        match c {
            // 空白
            ' ' | '\t' | '\n' | '\r' => i += 1,
            // 数字与小数点
            '0'..='9' | '.' => {
                let start = i;
                let mut dot_seen = false;
                while i < chars.len() {
                    let ch = chars[i];
                    if ch.is_ascii_digit() {
                        i += 1;
                    } else if ch == '.' {
                        if dot_seen {
                            return Err(format!(
                                "非法数字：'{}'",
                                chars[start..=i].iter().collect::<String>()
                            ));
                        }
                        dot_seen = true;
                        i += 1;
                    } else {
                        break;
                    }
                }
                let num_str: String = chars[start..i].iter().collect();
                let num = num_str
                    .parse::<f64>()
                    .map_err(|_| format!("无法解析数字：'{num_str}'"))?;
                tokens.push(Token::Num(num));
            }
            // 运算符与括号
            '+' => {
                tokens.push(Token::Plus);
                i += 1;
            }
            '-' => {
                tokens.push(Token::Minus);
                i += 1;
            }
            '*' => {
                tokens.push(Token::Star);
                i += 1;
            }
            '/' => {
                tokens.push(Token::Slash);
                i += 1;
            }
            '%' => {
                tokens.push(Token::Percent);
                i += 1;
            }
            '(' => {
                tokens.push(Token::LParen);
                i += 1;
            }
            ')' => {
                tokens.push(Token::RParen);
                i += 1;
            }
            // 未知字符
            _ => return Err(format!("未知字符：'{c}'")),
        }
    }
    Ok(tokens)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn 空字符串返回空序列() {
        assert_eq!(tokenize("").unwrap(), vec![]);
    }

    #[test]
    fn 跳过空白() {
        assert_eq!(
            tokenize("  1 + 2  ").unwrap(),
            vec![Token::Num(1.0), Token::Plus, Token::Num(2.0),]
        );
    }

    #[test]
    fn 解析小数() {
        assert_eq!(tokenize("2.5").unwrap(), vec![Token::Num(2.5)]);
    }

    #[test]
    fn 多个小数点报错() {
        assert!(tokenize("1.2.3").is_err());
    }

    #[test]
    fn 识别全部运算符与括号() {
        assert_eq!(
            tokenize("(1+2)*3-4/5%6").unwrap(),
            vec![
                Token::LParen,
                Token::Num(1.0),
                Token::Plus,
                Token::Num(2.0),
                Token::RParen,
                Token::Star,
                Token::Num(3.0),
                Token::Minus,
                Token::Num(4.0),
                Token::Slash,
                Token::Num(5.0),
                Token::Percent,
                Token::Num(6.0),
            ]
        );
    }

    #[test]
    fn 未知字符报错() {
        assert!(tokenize("1 & 2").is_err());
    }
}
