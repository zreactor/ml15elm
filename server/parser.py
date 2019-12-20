import bs4
import requests
import json

def get_soup_for_url(url):
    raw_data = requests.get(url).text
    return bs4.BeautifulSoup(raw_data)

def extract_heading_with_presenters(soup):
    for h3 in soup.find_all("h3"):
        if "登壇者" in h3.text:
            return h3

def get_presenter_items(h3_tag):
    all_next = h3_tag.find_all_next()
    
    p_items = [tag.next for tag in all_next if tag.name == "p"]
    string_items = [x for x in p_items if type(x)==bs4.element.NavigableString]

    found = []
    for item in string_items:
        _s = item.split("【")
        print(_s)
        if len(_s) < 2:
            break
        sub = item.next_sibling.next.next_sibling
        
        format_tag = f"{item.next_sibling.next.strip()}"
        if sub and sub.text:   # used to use contents
            format_tag = f"{format_tag}{sub.text}"
        info = f"{_s[0]} ------- ({format_tag})"
        found.append(info)
    print(found)
    return found[::-1]

def get_presenters_from_url(url):
    soup = get_soup_for_url(url)
    _h = extract_heading_with_presenters(soup)
    return get_presenter_items(_h)



