import React, { useState, useEffect } from 'react';
import { 
  Users, 
  FileText, 
  CheckCircle, 
  XCircle, 
  Download, 
  Eye,
  AlertCircle,
  Clock,
  Car,
  FileCheck,
  ArrowLeft,
  User,
  Shield,
  Lock,
  AlertTriangle,
  Info
} from 'lucide-react';
import api from '../services/api';

const DocumentVerification = () => {
  const [drivers, setDrivers] = useState([]);
  const [selectedDriver, setSelectedDriver] = useState(null);
  const [documents, setDocuments] = useState([]);
  const [selectedDocument, setSelectedDocument] = useState(null);
  const [loading, setLoading] = useState(true);
  const [actionLoading, setActionLoading] = useState(false);
  const [error, setError] = useState(null);
  const [view, setView] = useState('list'); // 'list', 'detail', or 'security'
  const [securityAnalysis, setSecurityAnalysis] = useState(null);
  const [encodedDocument, setEncodedDocument] = useState(null);

  useEffect(() => {
    fetchDrivers();
  }, []);

  const fetchDrivers = async () => {
    try {
      setLoading(true);
      const response = await api.get('/documents/admin/drivers');
      setDrivers(response.data || []);
      setError(null);
    } catch (err) {
      setError('Failed to load drivers');
      console.error('Error fetching drivers:', err);
    } finally {
      setLoading(false);
    }
  };

  const fetchUserDocuments = async (userId) => {
    try {
      setLoading(true);
      const response = await api.get(`/documents/admin/user/${userId}`);
      setDocuments(response.data || []);
      setError(null);
    } catch (err) {
      setError('Failed to load documents');
      console.error('Error fetching documents:', err);
    } finally {
      setLoading(false);
    }
  };

  const viewDocument = async (documentId) => {
    try {
      const response = await api.get(`/documents/admin/view/${documentId}`);
      setSelectedDocument(response.data);
    } catch (err) {
      setError('Failed to load document details');
      console.error('Error viewing document:', err);
    }
  };

  const downloadDocument = async (documentId, fileName) => {
    try {
      const response = await api.get(`/documents/admin/download/${documentId}`, {
        responseType: 'blob'
      });
      
      // Create download link
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement('a');
      link.href = url;
      link.setAttribute('download', fileName);
      document.body.appendChild(link);
      link.click();
      link.remove();
      window.URL.revokeObjectURL(url);
    } catch (err) {
      setError('Failed to download document');
      console.error('Error downloading document:', err);
    }
  };

  const approveDocument = async (documentId) => {
    try {
      setActionLoading(true);
      await api.put(`/documents/admin/approve/${documentId}`);
      
      // Refresh documents
      if (selectedDriver) {
        await fetchUserDocuments(selectedDriver.id);
      }
      await fetchDrivers();
      
      setSelectedDocument(null);
      setError(null);
    } catch (err) {
      setError('Failed to approve document');
      console.error('Error approving document:', err);
    } finally {
      setActionLoading(false);
    }
  };

  const rejectDocument = async (documentId) => {
    const reason = prompt('Enter rejection reason (optional):');
    
    try {
      setActionLoading(true);
      await api.put(`/documents/admin/reject/${documentId}`, {
        reason: reason || 'Document rejected'
      });
      
      // Refresh documents
      if (selectedDriver) {
        await fetchUserDocuments(selectedDriver.id);
      }
      await fetchDrivers();
      
      setSelectedDocument(null);
      setError(null);
    } catch (err) {
      setError('Failed to reject document');
      console.error('Error rejecting document:', err);
    } finally {
      setActionLoading(false);
    }
  };

  const loadSecurityAnalysis = async () => {
    try {
      setLoading(true);
      const response = await api.get('/documents/admin/security-analysis');
      setSecurityAnalysis(response.data);
      console.log('Security Analysis:', response.data);
    } catch (err) {
      setError('Failed to load security analysis');
      console.error('Error loading security analysis:', err);
    } finally {
      setLoading(false);
    }
  };

  const viewEncodedDocument = async (documentId) => {
    try {
      setLoading(true);
      const response = await api.get(`/documents/admin/view-encoded/${documentId}`);
      setEncodedDocument(response.data);
      console.log('Encoded Document loaded:', response.data);
      setError(null);
    } catch (err) {
      setError('Failed to load encoded document');
      console.error('Error loading encoded document:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleDriverClick = (driver) => {
    setSelectedDriver(driver);
    setSelectedDocument(null);
    setView('detail');
    fetchUserDocuments(driver.id);
  };

  const handleBackToList = () => {
    setView('list');
    setSelectedDriver(null);
    setDocuments([]);
    setSelectedDocument(null);
  };

  const getStatusBadge = (status) => {
    const badges = {
      Pending: { color: 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30', icon: Clock },
      Verified: { color: 'bg-green-500/20 text-green-400 border-green-500/30', icon: CheckCircle },
      Rejected: { color: 'bg-red-500/20 text-red-400 border-red-500/30', icon: XCircle },
    };
    
    // Default to Pending if status is null or undefined
    const displayStatus = status || 'Pending';
    const badge = badges[displayStatus] || badges.Pending;
    const Icon = badge.icon;
    
    return (
      <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium border ${badge.color}`}>
        <Icon className="w-3 h-3" />
        {displayStatus}
      </span>
    );
  };

  const getDocStatusBadge = (status) => {
    const badges = {
      Pending: { color: 'bg-yellow-500/20 text-yellow-400 border-yellow-500/30', icon: Clock },
      Approved: { color: 'bg-green-500/20 text-green-400 border-green-500/30', icon: CheckCircle },
      Rejected: { color: 'bg-red-500/20 text-red-400 border-red-500/30', icon: XCircle },
    };
    
    const badge = badges[status] || badges.Pending;
    const Icon = badge.icon;
    
    return (
      <span className={`inline-flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium border ${badge.color}`}>
        <Icon className="w-3 h-3" />
        {status}
      </span>
    );
  };

  // Drivers List View
  if (view === 'list') {
    if (loading) {
      return (
        <div className="flex items-center justify-center h-screen">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-500"></div>
        </div>
      );
    }

    return (
      <div className="p-6 space-y-6">
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold text-white flex items-center gap-3">
              <FileCheck className="w-8 h-8 text-green-500" />
              Document Verification
            </h1>
            <p className="text-gray-400 mt-2">
              Select a driver to review their profile and documents
            </p>
          </div>
          <button
            onClick={() => {
              setView('security');
              loadSecurityAnalysis();
            }}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg transition-colors"
          >
            <Shield className="w-5 h-5" />
            Security Analysis
          </button>
        </div>

        {error && (
          <div className="bg-red-500/10 border border-red-500/50 rounded-lg p-4 flex items-center gap-3">
            <AlertCircle className="w-5 h-5 text-red-400 flex-shrink-0" />
            <p className="text-red-400">{error}</p>
          </div>
        )}

        {/* Drivers Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {drivers.length === 0 ? (
            <div className="col-span-full bg-[#1e293b] rounded-xl border border-gray-700 p-12 text-center">
              <Users className="w-16 h-16 mx-auto mb-4 text-gray-600" />
              <p className="text-gray-400 text-lg">No drivers found</p>
            </div>
          ) : (
            drivers.map((driver) => (
              <div
                key={driver.id}
                onClick={() => handleDriverClick(driver)}
                className="bg-[#1e293b] rounded-xl border border-gray-700 p-6 cursor-pointer transition-all hover:border-green-500 hover:shadow-lg hover:shadow-green-500/20"
              >
                <div className="flex items-start justify-between mb-4">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-green-500 to-blue-500 flex items-center justify-center">
                      <User className="w-6 h-6 text-white" />
                    </div>
                    <div>
                      <h3 className="text-white font-semibold text-lg">{driver.name}</h3>
                      <p className="text-sm text-gray-400">{driver.email}</p>
                    </div>
                  </div>
                </div>
                
                <div className="space-y-2">
                  {driver.phone && (
                    <div className="text-sm text-gray-400">
                      📞 {driver.phone}
                    </div>
                  )}
                  
                  {driver.vehicle_model && (
                    <div className="flex items-center gap-2 text-sm text-gray-400">
                      <Car className="w-4 h-4" />
                      <span>{driver.vehicle_type} - {driver.vehicle_model}</span>
                    </div>
                  )}
                  
                  <div className="flex items-center justify-between pt-3 border-t border-gray-700">
                    <div>
                      {getStatusBadge(driver.verification_status)}
                    </div>
                    {driver.pending_documents > 0 && (
                      <div className="text-xs text-yellow-400 flex items-center gap-1">
                        <Clock className="w-3 h-3" />
                        {driver.pending_documents} pending
                      </div>
                    )}
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    );
  }

  // Driver Detail View
  if (view === 'security') {
    return (
      <SecurityAnalysisView 
        view={view}
        setView={setView}
        securityAnalysis={securityAnalysis}
        loading={loading}
        error={error}
        encodedDocument={encodedDocument}
      />
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header with Back Button */}
      <div className="flex items-center gap-4">
        <button
          onClick={handleBackToList}
          className="p-2 rounded-lg bg-[#1e293b] border border-gray-700 hover:border-green-500 transition-colors"
        >
          <ArrowLeft className="w-5 h-5 text-white" />
        </button>
        <div className="flex-1">
          <h1 className="text-3xl font-bold text-white flex items-center gap-3">
            <User className="w-8 h-8 text-green-500" />
            {selectedDriver?.name}
          </h1>
          <p className="text-gray-400 mt-1">
            {selectedDriver?.email}
          </p>
        </div>
        <div>
          {getStatusBadge(selectedDriver?.verification_status)}
        </div>
      </div>

      {error && (
        <div className="bg-red-500/10 border border-red-500/50 rounded-lg p-4 flex items-center gap-3">
          <AlertCircle className="w-5 h-5 text-red-400 flex-shrink-0" />
          <p className="text-red-400">{error}</p>
        </div>
      )}

      {/* Driver Info Card */}
      <div className="bg-[#1e293b] rounded-xl border border-gray-700 p-6">
        <h2 className="text-xl font-semibold text-white mb-4 flex items-center gap-2">
          <User className="w-5 h-5 text-green-500" />
          Driver Information
        </h2>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
          {selectedDriver?.phone && (
            <div>
              <p className="text-sm text-gray-400">Phone</p>
              <p className="text-white font-medium">{selectedDriver.phone}</p>
            </div>
          )}
          {selectedDriver?.vehicle_type && (
            <div>
              <p className="text-sm text-gray-400">Vehicle Type</p>
              <p className="text-white font-medium">{selectedDriver.vehicle_type}</p>
            </div>
          )}
          {selectedDriver?.vehicle_model && (
            <div>
              <p className="text-sm text-gray-400">Vehicle Model</p>
              <p className="text-white font-medium">{selectedDriver.vehicle_model}</p>
            </div>
          )}
          <div>
            <p className="text-sm text-gray-400">Joined</p>
            <p className="text-white font-medium">
              {new Date(selectedDriver?.created_at).toLocaleDateString()}
            </p>
          </div>
        </div>
      </div>

      {/* Documents Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Documents List */}
        <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
          <div className="bg-gradient-to-r from-blue-500/20 to-purple-500/20 px-4 py-3 border-b border-gray-700">
            <h2 className="text-lg font-semibold text-white flex items-center gap-2">
              <FileText className="w-5 h-5" />
              Documents ({documents.length})
            </h2>
          </div>
          
          <div className="divide-y divide-gray-700 max-h-[600px] overflow-y-auto">
            {loading ? (
              <div className="p-8 text-center">
                <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-500 mx-auto"></div>
              </div>
            ) : documents.length === 0 ? (
              <div className="p-8 text-center text-gray-400">
                <FileText className="w-12 h-12 mx-auto mb-3 opacity-50" />
                <p>No documents uploaded</p>
              </div>
            ) : (
              documents.map((doc) => (
                <div
                  key={doc.id}
                  onClick={() => viewDocument(doc.id)}
                  className={`p-4 cursor-pointer transition-colors ${
                    selectedDocument?.id === doc.id
                      ? 'bg-blue-500/10 border-l-4 border-blue-500'
                      : 'hover:bg-gray-700/50'
                  }`}
                >
                  <div className="flex items-start justify-between mb-2">
                    <div className="flex-1">
                      <h3 className="text-white font-medium">{doc.document_type}</h3>
                      <p className="text-sm text-gray-400 truncate">{doc.file_name}</p>
                    </div>
                    {getDocStatusBadge(doc.status)}
                  </div>
                  
                  <div className="text-xs text-gray-500 mt-2">
                    Uploaded: {new Date(doc.uploaded_at).toLocaleDateString()}
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Document Details */}
        <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
          <div className="bg-gradient-to-r from-purple-500/20 to-pink-500/20 px-4 py-3 border-b border-gray-700">
            <h2 className="text-lg font-semibold text-white flex items-center gap-2">
              <Eye className="w-5 h-5" />
              Document Details
            </h2>
          </div>
          
          <div className="p-6 max-h-[600px] overflow-y-auto">
            {!selectedDocument ? (
              <div className="p-8 text-center text-gray-400">
                <Eye className="w-12 h-12 mx-auto mb-3 opacity-50" />
                <p>Select a document to view details</p>
              </div>
            ) : (
              <div className="space-y-4">
                <div>
                  <label className="text-sm text-gray-400">Document Type</label>
                  <p className="text-white font-medium text-lg">{selectedDocument.document_type}</p>
                </div>
                
                <div>
                  <label className="text-sm text-gray-400">File Name</label>
                  <p className="text-white font-medium break-all">{selectedDocument.file_name}</p>
                </div>
                
                <div>
                  <label className="text-sm text-gray-400">File Size</label>
                  <p className="text-white font-medium">
                    {(selectedDocument.file_size / 1024).toFixed(2)} KB
                  </p>
                </div>
                
                <div>
                  <label className="text-sm text-gray-400">Status</label>
                  <div className="mt-1">
                    {getDocStatusBadge(selectedDocument.status)}
                  </div>
                </div>
                
                <div>
                  <label className="text-sm text-gray-400">Uploaded</label>
                  <p className="text-white font-medium">
                    {new Date(selectedDocument.uploaded_at).toLocaleString()}
                  </p>
                </div>
                
                {selectedDocument.verified_at && (
                  <div>
                    <label className="text-sm text-gray-400">Verified</label>
                    <p className="text-white font-medium">
                      {new Date(selectedDocument.verified_at).toLocaleString()}
                    </p>
                  </div>
                )}
                
                <div className="pt-4 space-y-3 border-t border-gray-700">
                  <button
                    onClick={() => downloadDocument(selectedDocument.id, selectedDocument.file_name)}
                    className="w-full bg-blue-600 hover:bg-blue-700 text-white py-3 px-4 rounded-lg flex items-center justify-center gap-2 transition-colors font-medium"
                  >
                    <Download className="w-5 h-5" />
                    Download Document
                  </button>
                  
                  <button
                    onClick={() => viewEncodedDocument(selectedDocument.id)}
                    className="w-full bg-purple-600 hover:bg-purple-700 text-white py-3 px-4 rounded-lg flex items-center justify-center gap-2 transition-colors font-medium"
                  >
                    <Lock className="w-5 h-5" />
                    View with Base64 Encoding
                  </button>
                  
                  {selectedDocument.status === 'Pending' && (
                    <>
                      <button
                        onClick={() => approveDocument(selectedDocument.id)}
                        disabled={actionLoading}
                        className="w-full bg-green-600 hover:bg-green-700 text-white py-3 px-4 rounded-lg flex items-center justify-center gap-2 transition-colors disabled:opacity-50 font-medium"
                      >
                        <CheckCircle className="w-5 h-5" />
                        {actionLoading ? 'Processing...' : 'Approve Document'}
                      </button>
                      
                      <button
                        onClick={() => rejectDocument(selectedDocument.id)}
                        disabled={actionLoading}
                        className="w-full bg-red-600 hover:bg-red-700 text-white py-3 px-4 rounded-lg flex items-center justify-center gap-2 transition-colors disabled:opacity-50 font-medium"
                      >
                        <XCircle className="w-5 h-5" />
                        {actionLoading ? 'Processing...' : 'Reject Document'}
                      </button>
                    </>
                  )}
                </div>
              </div>
            )}
          </div>
        </div>
        </div>
      </div>
    );
  
    // Security Analysis View - This should be checked before returning detail view
  };
  
  // Security Analysis View
  function SecurityAnalysisView({ view, setView, securityAnalysis, loading, error, encodedDocument }) {
    if (view === 'security') {
    return (
      <div className="p-6 space-y-6">
        {/* Header with Back Button */}
        <div className="flex items-center gap-4">
          <button
            onClick={() => setView('list')}
            className="p-2 rounded-lg bg-[#1e293b] border border-gray-700 hover:border-green-500 transition-colors"
          >
            <ArrowLeft className="w-5 h-5 text-white" />
          </button>
          <div className="flex-1">
            <h1 className="text-3xl font-bold text-white flex items-center gap-3">
              <Shield className="w-8 h-8 text-blue-500" />
              Base64 Encoding - Security Analysis
            </h1>
            <p className="text-gray-400 mt-1">
              Security levels, risks, and possible attacks
            </p>
          </div>
        </div>

        {error && (
          <div className="bg-red-500/10 border border-red-500/50 rounded-lg p-4 flex items-center gap-3">
            <AlertCircle className="w-5 h-5 text-red-400 flex-shrink-0" />
            <p className="text-red-400">{error}</p>
          </div>
        )}

        {loading ? (
          <div className="flex items-center justify-center p-12">
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-500"></div>
          </div>
        ) : securityAnalysis ? (
          <div className="space-y-6">
            {/* Security Level Card */}
            <div className="bg-[#1e293b] rounded-xl border border-gray-700 p-6">
              <h2 className="text-xl font-semibold text-white mb-4 flex items-center gap-2">
                <AlertTriangle className="w-6 h-6 text-red-500" />
                Security Level: {securityAnalysis.analysis.securityLevel}
              </h2>
              <p className="text-gray-300 mb-4">{securityAnalysis.analysis.description}</p>
              
              <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mt-4">
                <div className="bg-gray-800/50 rounded-lg p-3">
                  <p className="text-sm text-gray-400">Type</p>
                  <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.type}</p>
                </div>
                <div className="bg-gray-800/50 rounded-lg p-3">
                  <p className="text-sm text-gray-400">Reversible</p>
                  <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.reversible ? 'Yes ⚠️' : 'No'}</p>
                </div>
                <div className="bg-gray-800/50 rounded-lg p-3">
                  <p className="text-sm text-gray-400">Keys Required</p>
                  <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.keysRequired ? 'Yes' : 'No ⚠️'}</p>
                </div>
                <div className="bg-gray-800/50 rounded-lg p-3">
                  <p className="text-sm text-gray-400">Data Integrity</p>
                  <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.dataIntegrity ? 'Yes' : 'No ⚠️'}</p>
                </div>
                <div className="bg-gray-800/50 rounded-lg p-3">
                  <p className="text-sm text-gray-400">Confidentiality</p>
                  <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.confidentiality ? 'Yes' : 'No ⚠️'}</p>
                </div>
              </div>
            </div>

            {/* Security Risks */}
            <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
              <div className="bg-gradient-to-r from-red-500/20 to-orange-500/20 px-4 py-3 border-b border-gray-700">
                <h2 className="text-lg font-semibold text-white flex items-center gap-2">
                  <AlertTriangle className="w-5 h-5" />
                  Security Risks ({securityAnalysis.summary.riskCount})
                </h2>
              </div>
              <div className="p-6 space-y-4">
                {securityAnalysis.analysis.risks.map((risk, index) => {
                  const severityColor = risk.severity === 'HIGH' ? 'text-red-400 bg-red-500/20 border-red-500/30' : 
                                       risk.severity === 'MEDIUM' ? 'text-yellow-400 bg-yellow-500/20 border-yellow-500/30' : 
                                       'text-green-400 bg-green-500/20 border-green-500/30';
                  return (
                    <div key={index} className="bg-gray-800/50 rounded-lg p-4 border border-gray-700">
                      <div className="flex items-start justify-between mb-2">
                        <h3 className="text-white font-medium text-lg">{risk.risk}</h3>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium border ${severityColor}`}>
                          {risk.severity}
                        </span>
                      </div>
                      <p className="text-gray-400 text-sm mb-2">{risk.description}</p>
                      <p className="text-gray-300 text-sm"><strong>Impact:</strong> {risk.impact}</p>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Possible Attacks */}
            <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
              <div className="bg-gradient-to-r from-purple-500/20 to-pink-500/20 px-4 py-3 border-b border-gray-700">
                <h2 className="text-lg font-semibold text-white flex items-center gap-2">
                  <Lock className="w-5 h-5" />
                  Possible Attacks ({securityAnalysis.summary.attackCount})
                </h2>
              </div>
              <div className="p-6 space-y-4">
                {securityAnalysis.analysis.possibleAttacks.map((attack, index) => {
                  const difficultyColor = attack.difficulty === 'TRIVIAL' || attack.difficulty === 'EASY' 
                    ? 'text-red-400 bg-red-500/20 border-red-500/30' 
                    : attack.difficulty === 'MEDIUM' 
                    ? 'text-yellow-400 bg-yellow-500/20 border-yellow-500/30'
                    : 'text-green-400 bg-green-500/20 border-green-500/30';
                  return (
                    <div key={index} className="bg-gray-800/50 rounded-lg p-4 border border-gray-700">
                      <div className="flex items-start justify-between mb-2">
                        <h3 className="text-white font-medium text-lg">{attack.attack}</h3>
                        <span className={`px-2 py-1 rounded-full text-xs font-medium border ${difficultyColor}`}>
                          {attack.difficulty}
                        </span>
                      </div>
                      <p className="text-gray-400 text-sm mb-2">{attack.description}</p>
                      <p className="text-blue-300 text-sm"><strong>Mitigation:</strong> {attack.mitigation}</p>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Recommendations */}
            <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
              <div className="bg-gradient-to-r from-green-500/20 to-blue-500/20 px-4 py-3 border-b border-gray-700">
                <h2 className="text-lg font-semibold text-white flex items-center gap-2">
                  <Info className="w-5 h-5" />
                  Security Recommendations
                </h2>
              </div>
              <div className="p-6">
                <ul className="space-y-2">
                  {securityAnalysis.analysis.recommendations.map((rec, index) => (
                    <li key={index} className="flex items-start gap-2 text-gray-300">
                      <span className="text-green-400 mt-1">✓</span>
                      <span>{rec}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            {/* Encoded Document Display */}
            {encodedDocument && (
              <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
                <div className="bg-gradient-to-r from-blue-500/20 to-purple-500/20 px-4 py-3 border-b border-gray-700">
                  <h2 className="text-lg font-semibold text-white flex items-center gap-2">
                    <Lock className="w-5 h-5" />
                    Encoded Document: {encodedDocument.document.file_name}
                  </h2>
                </div>
                <div className="p-6 space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div>
                      <p className="text-sm text-gray-400">Encoding Technique</p>
                      <p className="text-white font-medium">{encodedDocument.encoding.technique}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-400">Overhead</p>
                      <p className="text-white font-medium">{encodedDocument.encoding.overhead}</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-400">Original Size</p>
                      <p className="text-white font-medium">{encodedDocument.encoding.originalSize} bytes</p>
                    </div>
                    <div>
                      <p className="text-sm text-gray-400">Encoded Size</p>
                      <p className="text-white font-medium">{encodedDocument.encoding.encodedSize} bytes</p>
                    </div>
                  </div>
                  <div>
                    <p className="text-sm text-gray-400 mb-2">Base64 Encoded Data (Preview)</p>
                    <div className="bg-gray-900 rounded-lg p-4 max-h-64 overflow-auto">
                      <code className="text-green-400 text-xs break-all font-mono">
                        {encodedDocument.encodedData.substring(0, 500)}...
                      </code>
                    </div>
                    <p className="text-gray-500 text-xs mt-2">
                      Note: This is a preview. Full encoded data is available via API.
                    </p>
                  </div>
                </div>
              </div>
            )}
          </div>
        ) : (
          <div className="bg-[#1e293b] rounded-xl border border-gray-700 p-12 text-center">
            <Shield className="w-16 h-16 mx-auto mb-4 text-gray-600" />
            <p className="text-gray-400 text-lg">Click "View Security Analysis" to load security information</p>
          </div>
        )}
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6">
      {/* Header with Back Button */}
      <div className="flex items-center gap-4">
        <button
          onClick={() => setView('list')}
          className="p-2 rounded-lg bg-[#1e293b] border border-gray-700 hover:border-green-500 transition-colors"
        >
          <ArrowLeft className="w-5 h-5 text-white" />
        </button>
        <div className="flex-1">
          <h1 className="text-3xl font-bold text-white flex items-center gap-3">
            <Shield className="w-8 h-8 text-blue-500" />
            Base64 Encoding - Security Analysis
          </h1>
          <p className="text-gray-400 mt-1">
            Security levels, risks, and possible attacks
          </p>
        </div>
      </div>

      {error && (
        <div className="bg-red-500/10 border border-red-500/50 rounded-lg p-4 flex items-center gap-3">
          <AlertCircle className="w-5 h-5 text-red-400 flex-shrink-0" />
          <p className="text-red-400">{error}</p>
        </div>
      )}

      {loading ? (
        <div className="flex items-center justify-center p-12">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-green-500"></div>
        </div>
      ) : securityAnalysis ? (
        <div className="space-y-6">
          {/* Security Level Card */}
          <div className="bg-[#1e293b] rounded-xl border border-gray-700 p-6">
            <h2 className="text-xl font-semibold text-white mb-4 flex items-center gap-2">
              <AlertTriangle className="w-6 h-6 text-red-500" />
              Security Level: {securityAnalysis.analysis.securityLevel}
            </h2>
            <p className="text-gray-300 mb-4">{securityAnalysis.analysis.description}</p>
            
            <div className="grid grid-cols-2 md:grid-cols-5 gap-4 mt-4">
              <div className="bg-gray-800/50 rounded-lg p-3">
                <p className="text-sm text-gray-400">Type</p>
                <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.type}</p>
              </div>
              <div className="bg-gray-800/50 rounded-lg p-3">
                <p className="text-sm text-gray-400">Reversible</p>
                <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.reversible ? 'Yes ⚠️' : 'No'}</p>
              </div>
              <div className="bg-gray-800/50 rounded-lg p-3">
                <p className="text-sm text-gray-400">Keys Required</p>
                <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.keysRequired ? 'Yes' : 'No ⚠️'}</p>
              </div>
              <div className="bg-gray-800/50 rounded-lg p-3">
                <p className="text-sm text-gray-400">Data Integrity</p>
                <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.dataIntegrity ? 'Yes' : 'No ⚠️'}</p>
              </div>
              <div className="bg-gray-800/50 rounded-lg p-3">
                <p className="text-sm text-gray-400">Confidentiality</p>
                <p className="text-white font-medium">{securityAnalysis.analysis.characteristics.confidentiality ? 'Yes' : 'No ⚠️'}</p>
              </div>
            </div>
          </div>

          {/* Security Risks */}
          <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
            <div className="bg-gradient-to-r from-red-500/20 to-orange-500/20 px-4 py-3 border-b border-gray-700">
              <h2 className="text-lg font-semibold text-white flex items-center gap-2">
                <AlertTriangle className="w-5 h-5" />
                Security Risks ({securityAnalysis.summary.riskCount})
              </h2>
            </div>
            <div className="p-6 space-y-4">
              {securityAnalysis.analysis.risks.map((risk, index) => {
                const severityColor = risk.severity === 'HIGH' ? 'text-red-400 bg-red-500/20 border-red-500/30' : 
                                     risk.severity === 'MEDIUM' ? 'text-yellow-400 bg-yellow-500/20 border-yellow-500/30' : 
                                     'text-green-400 bg-green-500/20 border-green-500/30';
                return (
                  <div key={index} className="bg-gray-800/50 rounded-lg p-4 border border-gray-700">
                    <div className="flex items-start justify-between mb-2">
                      <h3 className="text-white font-medium text-lg">{risk.risk}</h3>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium border ${severityColor}`}>
                        {risk.severity}
                      </span>
                    </div>
                    <p className="text-gray-400 text-sm mb-2">{risk.description}</p>
                    <p className="text-gray-300 text-sm"><strong>Impact:</strong> {risk.impact}</p>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Possible Attacks */}
          <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
            <div className="bg-gradient-to-r from-purple-500/20 to-pink-500/20 px-4 py-3 border-b border-gray-700">
              <h2 className="text-lg font-semibold text-white flex items-center gap-2">
                <Lock className="w-5 h-5" />
                Possible Attacks ({securityAnalysis.summary.attackCount})
              </h2>
            </div>
            <div className="p-6 space-y-4">
              {securityAnalysis.analysis.possibleAttacks.map((attack, index) => {
                const difficultyColor = attack.difficulty === 'TRIVIAL' || attack.difficulty === 'EASY' 
                  ? 'text-red-400 bg-red-500/20 border-red-500/30' 
                  : attack.difficulty === 'MEDIUM' 
                  ? 'text-yellow-400 bg-yellow-500/20 border-yellow-500/30'
                  : 'text-green-400 bg-green-500/20 border-green-500/30';
                return (
                  <div key={index} className="bg-gray-800/50 rounded-lg p-4 border border-gray-700">
                    <div className="flex items-start justify-between mb-2">
                      <h3 className="text-white font-medium text-lg">{attack.attack}</h3>
                      <span className={`px-2 py-1 rounded-full text-xs font-medium border ${difficultyColor}`}>
                        {attack.difficulty}
                      </span>
                    </div>
                    <p className="text-gray-400 text-sm mb-2">{attack.description}</p>
                    <p className="text-blue-300 text-sm"><strong>Mitigation:</strong> {attack.mitigation}</p>
                  </div>
                );
              })}
            </div>
          </div>

          {/* Recommendations */}
          <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
            <div className="bg-gradient-to-r from-green-500/20 to-blue-500/20 px-4 py-3 border-b border-gray-700">
              <h2 className="text-lg font-semibold text-white flex items-center gap-2">
                <Info className="w-5 h-5" />
                Security Recommendations
              </h2>
            </div>
            <div className="p-6">
              <ul className="space-y-2">
                {securityAnalysis.analysis.recommendations.map((rec, index) => (
                  <li key={index} className="flex items-start gap-2 text-gray-300">
                    <span className="text-green-400 mt-1">✓</span>
                    <span>{rec}</span>
                  </li>
                ))}
              </ul>
            </div>
          </div>

          {/* Encoded Document Display */}
          {encodedDocument && (
            <div className="bg-[#1e293b] rounded-xl border border-gray-700 overflow-hidden">
              <div className="bg-gradient-to-r from-blue-500/20 to-purple-500/20 px-4 py-3 border-b border-gray-700">
                <h2 className="text-lg font-semibold text-white flex items-center gap-2">
                  <Lock className="w-5 h-5" />
                  Encoded Document: {encodedDocument.document.file_name}
                </h2>
              </div>
              <div className="p-6 space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-gray-400">Encoding Technique</p>
                    <p className="text-white font-medium">{encodedDocument.encoding.technique}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-400">Overhead</p>
                    <p className="text-white font-medium">{encodedDocument.encoding.overhead}</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-400">Original Size</p>
                    <p className="text-white font-medium">{encodedDocument.encoding.originalSize} bytes</p>
                  </div>
                  <div>
                    <p className="text-sm text-gray-400">Encoded Size</p>
                    <p className="text-white font-medium">{encodedDocument.encoding.encodedSize} bytes</p>
                  </div>
                </div>
                <div>
                  <p className="text-sm text-gray-400 mb-2">Base64 Encoded Data (Preview)</p>
                  <div className="bg-gray-900 rounded-lg p-4 max-h-64 overflow-auto">
                    <code className="text-green-400 text-xs break-all font-mono">
                      {encodedDocument.encodedData.substring(0, 500)}...
                    </code>
                  </div>
                  <p className="text-gray-500 text-xs mt-2">
                    Note: This is a preview. Full encoded data is available via API.
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>
      ) : (
        <div className="bg-[#1e293b] rounded-xl border border-gray-700 p-12 text-center">
          <Shield className="w-16 h-16 mx-auto mb-4 text-gray-600" />
          <p className="text-gray-400 text-lg">Click "View Security Analysis" to load security information</p>
        </div>
      )}
    </div>
  );
}

export default DocumentVerification;