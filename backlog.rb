require 'rubygems'
require 'sinatra'
require 'rexml/document'
require 'rexml/xpath'
require 'rexml/element'

helpers do
  def load_backlog
    REXML::Document.new(File.read("backlogs/#{@backlog}.xml"))
  end
  
  def write_backlog(doc)
    File.open("backlogs/#{@backlog}.xml", 'w') do |f|
      doc.write(f,0)
    end  
  end

  def render_backlog
    doc = load_backlog
    @title = doc.root.attribute('title')
    @items = doc.root.elements.map {|item| 
      hash = {}
      hash[:id] = item.attribute('id')
      item.each_element do |attribute|
        hash[attribute.name.to_sym] = attribute.text
      end
      hash
    }.sort {|a,b| b[:importance].to_i <=> a[:importance].to_i}
    erb :backlog
  end  
  
  def create_backlog
    doc = REXML::Document.new
    root = doc.add_element('backlog')
    root.add_attribute('title',params[:title])
    write_backlog(doc)
  end
  
  def update_backlog
    doc = load_backlog
    doc.root.add_attribute('title', params[:title])
    write_backlog(doc)
  end
  
  def max_id(doc)
    max_id = 0
    doc.root.elements.each do |element|
      id = element.attribute('id').to_s.to_i
      max_id = id if id > max_id
    end
    max_id
  end  
end  

get '/' do
  @backlogs = Dir.glob("backlogs/*.xml").map {|f| f.match(/backlogs\/(.+)\.xml/)[1]}
  erb :backlog_list
end

get '/:backlog' do
  @backlog = "#{params[:backlog]}"
  if File.exist?("backlogs/#{@backlog}.xml")
    render_backlog
  else
    erb :new_backlog
  end
end

put '/:backlog' do
  @backlog = params[:backlog]
  if File.exist?("backlogs/#{@backlog}.xml")
    update_backlog
  else
    create_backlog 
  end
  redirect("/#{@backlog}")  
end

post '/:backlog' do
  @backlog = params[:backlog]
  if params[:name].nil? || params[:name] == "" || 
        params[:importance].nil? || params[:importance] == ""
     @error_message = "Name and importance field must be filled out"
     render_backlog
  else 
    doc = load_backlog
    item = doc.root.add_element 'item'
    item.add_attribute('id', (max_id(doc) + 1).to_s)
    params[:importance] = params[:importance].to_i
    [:importance, :name, :notes, :demo, :estimate].each do |attribute|
      el = item.add_element(attribute.to_s)
      el.text = params[attribute]
    end
    write_backlog(doc)
    redirect("/#{@backlog}")
  end
end

post '/:backlog/:id' do
  [:name, :importance].each do |att|
    params[att] = nil if params[att] && params[att] == ""
  end
  params[:importance] = params[:importance].to_i if params[:importance]
  @backlog = params[:backlog]
  doc = load_backlog
  item = REXML::XPath.first(doc, "//item[@id='#{params[:id]}']")
  item.each_element do |el|
    el.text = params[el.name.to_sym] if params[el.name.to_sym]
  end
  write_backlog(doc)
  redirect("/#{@backlog}")
end

post '/:backlog/delete/:id' do
  @backlog = params[:backlog]
  doc = load_backlog
#  doc.root.delete_element doc.root.elements.find {|e| e.find {|att| att.name == 'id'}.text == params[:id]}
  item = REXML::XPath.first(doc, "//item[@id='#{params[:id]}']")
  doc.root.delete_element(item)
  write_backlog(doc)
  redirect("/#{@backlog}")
end