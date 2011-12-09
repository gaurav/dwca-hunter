# encoding: utf-8
class DwcaHunter
  class ResourceWikipediaRu
    PAGE_START_RE = /^\s*\<page\>\s*$/
    TITLE_RE      = /\<title\>(.*)\<\/title\>/
    ID_RE         = /^\s*\<id\>(.*)\<\/id\>\s*$/
    EN_TAXON_RE   = /\{\{taxobox\s/i
    RU_TAXON_RE   = /\{\{таксон\s/i
    TAXON_END_RE  = /^\|?\s*\}\}/
    PAGE_END_RE   = /^\s*\<\/page\>\s*$/
    SEPARATOR     = "|||***|||\n" 
    def initialize(file_path = nil)
      @file_path = file_path
    end  
    
    def process
      @file_handle = @file_path ? open(file_path, 'r:utf-8') : fetch_file
    end

  end
end
__END__
#!/usr/bin/env ruby

# encoding: utf-8

page_start = /^\s*\<page\>\s*$/
title_re = /\<title\>(.*)\<\/title\>/
id_re = /^\s*\<id\>(.*)\<\/id\>\s*$/
en_taxon = /\{\{taxobox\s/i
ru_taxon = /\{\{таксон\s/i
taxon_end = /^\|?\s*\}\}/
separator = "|||***|||\n" 
page_end = /^\s*\<\/page\>\s*$/

f = open('ruwiki-latest-pages-articles.xml', 'r:utf-8')
res = open('ru_names', 'w:utf-8')
species_on = false
get_page_info = false
title = nil
id = nil
count = 0
f.each do |l|
  if !get_page_info && l.match(page_start)
    get_page_info = true
  elsif get_page_info
    if title_match = l.match(title_re)
      title = title_match[1] 
    elsif id_match = l.match(id_re)
      id = id_match[1]
      get_page_info = false
    end
  end
  if !species_on && (l.match(en_taxon) || l.match(ru_taxon))
    species_on = true
    res.write(separator)
    res.write("title:" + title + "\n")
    res.write("id:" + id + "\n")
    count += 1
    puts count
    res.write(l)
  elsif species_on
    res.write(l)
  end
  species_on = false if (l.match(taxon_end) || l.match(page_end))
end

f.close
res.close
