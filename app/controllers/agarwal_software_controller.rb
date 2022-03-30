class AgarwalSoftwareController < ApplicationController
  def index
  end

  def uploadqcdn
    uploaded_io = params[:file_qcdn]
    File.open(Rails.root.join('public', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
    response = PdfTable.new.convert_pdf uploaded_io.original_filename
    if response == 200
      render json: { status: "Success", filename: uploaded_io.original_filename}
    else
      render json: {status: "Failure"}
    end
  end

  def uploadjk
    uploaded_io = params[:file_jk]
    file1_filename = params[:file1_filename]
    File.open(Rails.root.join('public', uploaded_io.original_filename), 'wb') do |file|
      file.write(uploaded_io.read)
    end
    response = PdfTable.new.convert_pdf(uploaded_io.original_filename)
    if response == 200
      res = PdfTable.new.compare_product(file1_filename.gsub(".pdf", ""), uploaded_io.original_filename.gsub(".pdf", ""))
      render json: { status: "Success", hash_file_1: res[0], hash_file2: res[1], file1_name: file1_filename, file2_name: uploaded_io.original_filename}
    else
      render json: {status: "Failure"}
    end
  end

  def compare
  end

  def compare1
    res = PdfTable.new.compare("qcdnb00294", "jk1")
    render json: {hash_file_1: res[0], hash_file2: res[1], file1_name: "qcdnb00294.pdf", file2_name: "jk1.pdf"}
  end

  def compare_product
  end

  def compare_product1
    res = PdfTable.new.compare_product("qcdnb00294", "jk1")
    render json: {hash_file_1: res[0], hash_file2: res[1], file1_name: "qcdnb00294.pdf", file2_name: "jk1.pdf"}
  end
end
