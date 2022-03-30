class PdfTable
  include HTTParty

  def convert_pdf(filename)
    response ||= self.class.post("https://pdftables.com/api?key=tp3o248qs8jc&format=html", body: {file: File.open("public/#{filename}")})
    if response.code == 200
      File.open('response.html', 'w') do |f|
        f.puts response
      end
      convert filename
    end
    response.code
  end

  def convert filename
    f = File.open("response.html")
    doc = Nokogiri::HTML(f)
    csv = CSV.open("file_#{filename.gsub(".pdf", "")}.csv", 'w')
    new_array = []
    doc.xpath('//table/tr').each do |row|
      tarray = []
      row.xpath('td').each do |cell|
        if cell.xpath('br').count > 0
          tarray << cell.children.first.text
          new_array << cell.children.last.text
        else
          tarray << cell.text
        end
      end
      csv << tarray
      if new_array.count > 0
        csv << new_array
        new_array = []
      end
    end
    csv.close
    File.delete("public/#{filename}")
    File.delete("response.html")
  end

  def convert_jk_pdf filename
    response ||= self.class.post("https://pdftables.com/api?key=tp3o248qs8jc&format=csv", body: {file: File.open("public/#{filename}")})
    if response.code == 200
      File.open('file2.csv', 'w') do |f|
        f.puts response
      end
      File.delete("public/#{filename}")
      compare
    end    
  end

  def compare(file1, file2)
    hash_file1 = {}
    hash_file2 = {}
    header = []
    batch = -1
    expire = -1
    mrp = -1
    File.open("file_#{file1}.csv").each do |row|
      row = row.downcase.split(",").compact unless row.is_a?(Array)
      if row.include?("batch")
        header = row
        batch = header.index("batch")
        expire = header.index("exp.")
        mrp = header.index("m.r.p")
      elsif header.length > 0 && header.length == row.length
        date = row[expire].split("/")
        final_date =  date[0].length == 1 ? "0#{row[expire]}" : row[expire]
        if hash_file1["#{row[batch]}-#{final_date}-#{row[mrp]}"].nil?
          i = 0
          h = {}
          header.each{|a| h[a] = row[i]; i = i + 1 }
          hash_file1["#{row[batch]}-#{final_date}-#{row[mrp]}"] = h
        else
          hash_file1["#{row[batch]}-#{final_date}-#{row[mrp]}"]["quantity"] = hash_file1["#{row[batch]}-#{final_date}-#{row[mrp]}"]["quantity"].to_i + 1
        end
      end
    end
    # batch = -1
    # expire = -1
    # mrp = -1
    # header = []
    # hash_file2 = {}
    # csv_file = CSV.open("file2.csv")
    # csv_file.each do |row|
    #   # row = row.downcase.split(",").compact
    #   # row = row.map(&:downcase)
    #   # if csv_file.lineno > 120
    #   #   binding.pry
    #   # end
    #   if header.length > 0 && !(row.include?("BATCH"))
    #     binding.pry
    #     row[1] = row[1..5].join("").gsub(" ","") if row[1..5]
    #     row_delete = row.length == 18 ? 7 : 4
    #     i = 0
    #     while i<row_delete
    #       row.delete_at(2)
    #       i +=1
    #     end
    #     if row.length > header.length
    #       row.delete_at(9)
    #       row.delete_at(row.length - 1)
    #     end
    #   end
    #   if row.include?("BATCH") && header.length == 0
    #     # row = row.select{|a| a unless a.empty? }
    #     row = row.compact
    #     row[1] = row[1..3].join("").gsub(" ","")
    #     row.delete_at(2)
    #     row.delete_at(2)
    #     header = row
    #     batch = header.index("BATCH")
    #     expire = header.index("EXPIR")
    #     mrp = header.index("M.R.P")
    #   elsif header.length > 0 && header.length == row.length && row[expire] && !(row.include?("BATCH"))
    #     if hash_file2["#{row[batch]&.downcase}-#{row[expire].gsub("-", "/")}-#{row[mrp]}"].nil?
    #       i = 0
    #       h = {}
    #       header.each{|a| h[a] = row[i]; i = i + 1 }
    #       hash_file2["#{row[batch]&.downcase}-#{row[expire].gsub("-", "/")}-#{row[mrp]}"] = h
    #     else
    #       hash_file2["#{row[batch]&.downcase}-#{row[expire].gsub("-", "/")}-#{row[mrp]}"]["QNTY"] = hash_file2["#{row[batch]&.downcase}-#{row[expire].gsub("-", "/")}-#{row[mrp]}"]["QNTY"].to_i + 1
    #     end
    #   end
    # end
    batch = -1
    expire = -1
    mrp = -1
    header = []
    hash_file2 = {}
    csv_file = CSV.open("file_#{file2}.csv")
    csv_file.each do |row|
      # row = row.downcase.split(",").compact
      # row = row.map(&:downcase)
      # if csv_file.lineno > 138
      #   binding.pry
      # end
      if header.length > 0 && !(row.include?("BATCH")) && header.length < row.length
        # binding.pry
        row_delete = row.length == 12 ? 1 : 2
        join_no =  row_delete == 1 ? 2 : 3
        row[1] = row[1..join_no].join("").gsub(" ","") if row[1..3]
        i = 0
        while i<row_delete
          row.delete_at(2)
          i +=1
        end
        if row.length > header.length
          row.delete_at(9)
          row.delete_at(row.length - 1)
        end
      elsif header.length == (row.length + 1)
        row.insert(6, "")
      end
      if row.include?("BATCH") && header.length == 0
        # row = row.select{|a| a unless a.empty? }
        # binding.pry
        row = row.compact
        row[1] = row[1..4].join("").gsub(" ","")
        row.delete_at(2)
        row.delete_at(2)
        row.delete_at(2)
        header = row
        batch = header.index("BATCH")
        expire = header.index("EXPIR")
        mrp = header.index("M.R.P")
      elsif header.length > 0 && header.length == row.length && row[expire] && !(row.include?("BATCH"))
        if hash_file2["#{row[batch]&.downcase}-#{row[expire].gsub("-", "/")}-#{row[mrp]}"].nil?
          i = 0
          h = {}
          header.each{|a| h[a] = row[i]; i = i + 1 }
          hash_file2["#{row[batch]&.downcase}-#{row[expire].gsub("-", "/")}-#{row[mrp]}"] = h
        else
          hash_file2["#{row[batch]&.downcase}-#{row[expire].gsub("-", "/")}-#{row[mrp]}"]["QNTY"] = hash_file2["#{row[batch]&.downcase}-#{row[expire].gsub("-", "/")}-#{row[mrp]}"]["QNTY"].to_i + 1
        end
      end
    end
    puts hash_file2
    [hash_file1, hash_file2]
  end


  def compare_product(file1, file2)
    hash_file1 = {}
    hash_file2 = {}
    header = []
    product = -1
    batch = -1
    File.open("file_#{file1}.csv").each do |row|
      row = row.downcase.split(",").compact unless row.is_a?(Array)
      if row.include?("batch")
        header = row
        product = header.index("product")
        batch = header.index("batch")
      elsif header.length > 0 && header.length == row.length
        product_value = row[product].downcase.gsub(" ", "").gsub("tab", "").gsub("cap", "")
        if hash_file1["#{product_value}"].nil? && hash_file1.values.find{|a| a["batch"].downcase == row[batch].downcase}.nil?
          i = 0
          h = {}
          header.each{|a| h[a] = row[i]; i = i + 1 }
          hash_file1["#{product_value}"] = h
        elsif hash_file1["#{product_value}"].nil?
          key = hash_file1.key(hash_file1.values.find{|a| a["batch"].downcase == row[batch].downcase})
          hash_file1[key]["quantity"] = hash_file1[key]["quantity"].to_i + 1
        else
          hash_file1["#{product_value}"]["quantity"] = hash_file1["#{product_value}"]["quantity"].to_i + 1
        end
      end
    end
    
    product = -1
    batch = -1
    header = []
    hash_file2 = {}
    csv_file = CSV.open("file_#{file2}.csv")
    csv_file.each do |row|
      if header.length > 0 && !(row.include?("BATCH")) && header.length < row.length
        row_delete = row.length == 12 ? 1 : (row.length == 15 ? 4 : 2)
        join_no =  row_delete == 1 ? 2 : 3
        row[1] = row[1..join_no].join("").gsub(" ","") if row[1..3]
        i = 0
        while i<row_delete
          row.delete_at(2)
          i +=1
        end
        if row.length > header.length
          row.delete_at(9)
          row.delete_at(row.length - 1)
        end
      elsif header.length == (row.length + 1)
        row.insert(6, "")
      end
      if row.include?("BATCH") && header.length == 0
        # row = row.select{|a| a unless a.empty? }
        # binding.pry
        row = row.compact
        row[1] = row[1..4].join("").gsub(" ","")
        row.delete_at(2)
        row.delete_at(2)
        row.delete_at(2)
        header = row
        product = header.index("PRODUCT")
        batch = header.index("BATCH")
      elsif header.length > 0 && header.length == row.length && !(row.include?("BATCH"))
        product_value = row[product].downcase.gsub(" ", "").gsub("tab", "").gsub("cap", "")
        if hash_file2["#{product_value}"].nil? && hash_file2.values.find{|a| a["BATCH"].downcase == row[batch].downcase}.nil?
          i = 0
          h = {}
          header.each{|a| h[a] = row[i]; i = i + 1 }
          hash_file2["#{product_value}"] = h
        elsif hash_file2["#{product_value}"].nil?
          key = hash_file2.key(hash_file2.values.find{|a| a["BATCH"].downcase == row[batch].downcase})
          hash_file2[key]["QNTY"] = hash_file2[key]["QNTY"].to_i + 1
        else
          hash_file2["#{product_value}"]["QNTY"] = hash_file2["#{product_value}"]["QNTY"].to_i + 1
        end
      end
    end
    puts hash_file2
    [hash_file1, hash_file2]
  end
end
