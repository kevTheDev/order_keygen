require 'spec_helper'

describe Order do
  
  describe 'Validations' do
    
    subject { create(:order) }
    
    it { should validate_presence_of(:shopify_id) }
    it { should validate_uniqueness_of(:shopify_id) }
    
  end
  # Validations
  
  describe 'Creation' do
    
    it { should allow_mass_assignment_of(:shopify_id) }
    
  end
  # Creation
  
end